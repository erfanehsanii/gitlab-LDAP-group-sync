#!/bin/bash

# Define the container name or ID
CONTAINER_NAME="your_gitlab_container_name_or_id"

# Define the path to the Ruby script
SCRIPT_PATH="/path/to/your/repo/script.rb"

# Execute the script inside the Docker container
docker exec -i $CONTAINER_NAME gitlab-rails runner -e production "$(cat $SCRIPT_PATH)"

