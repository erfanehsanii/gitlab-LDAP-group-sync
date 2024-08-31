require 'net/ldap'

# Define LDAP connection parameters
ldap = Net::LDAP.new(
  host: 'rm-dkdc01.digikala.com',
  port: 389,
  auth: {
    method: :simple,
    username: 'CN=NOCGitlab,OU=Groups,OU=NOC,OU=Enterprise Services,DC=digikala,DC=COM',
    password: '#6YdbH36aD'
  }
)

# Define the Git-Admin group DN
git_admin_group_dn = 'CN=Git-Admin,OU=Groups,OU=NOC,OU=Enterprise Services,DC=digikala,DC=COM'

# Fetch all LDAP users in GitLab
ldap_users = User.joins(:identities).where('identities.extern_uid IS NOT NULL')

ldap_users.each do |user|
  # Search for the user in LDAP using their extern_uid
  filter = Net::LDAP::Filter.eq('sAMAccountName', user.username)
  ldap_entry = nil

  ldap.search(base: 'DC=digikala,DC=com', filter: filter) do |entry|
    ldap_entry = entry
  end

  # Check if the user is in the Git-Admin group
  if ldap_entry
    member_of = ldap_entry[:memberOf] || []
    if member_of.include?(git_admin_group_dn)
      # Grant admin rights if they are in the Git-Admin group
      unless user.admin?
        user.admin = true
        user.save!
        puts "Admin access granted to #{user.username}"
      else
        puts "#{user.username} already has admin access"
      end
    else
      # Optionally revoke admin rights if they are not in the Git-Admin group
      if user.admin?
        user.admin = false
        user.save!
        puts "Admin access revoked for #{user.username}"
      end
    end
  else
    puts "LDAP entry not found for #{user.username}"
  end
end

