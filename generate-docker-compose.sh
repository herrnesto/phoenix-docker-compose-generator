#!/bin/bash

# Set the output file name for the Docker Compose file
output_file="docker-compose.yml"

# Get the project name from config
project_name=$(grep -E "config :huugo, Huugo.Repo," ./config/dev.exs | awk -F '[,]' '{print $1}' | awk '{print $2}' | tr -d ':')

# Start writing the Docker Compose file
cat <<EOL > $output_file
version: '3'
services:
EOL

# Extract database configuration from dev.exs
dev_db_username=$(grep -E "username:" ./config/dev.exs | awk '{print $2}' | tr -d '",')
dev_db_password=$(grep -E "password:" ./config/dev.exs | awk '{print $2}' | tr -d '",')
dev_db_database=$(grep -E "database:" ./config/dev.exs | awk '{print $2}' | tr -d '",')

# Extract the test database name and remove everything after the '#'
test_db_name_with_partition=$(grep -E "database:" ./config/test.exs | awk '{print $2}' | tr -d '",')
test_db_name=$(echo $test_db_name_with_partition | awk -F '#' '{print $1}')

# Write PostgreSQL service definitions to the Docker Compose file
cat <<EOL >> $output_file
  ${project_name}_postgres_dev:
    image: postgres:latest
    container_name: ${project_name}_postgres_dev
    environment:
      POSTGRES_USER: $dev_db_username
      POSTGRES_PASSWORD: $dev_db_password
      POSTGRES_DB: $dev_db_database
    ports:
      - "5432:5432"

  ${project_name}_postgres_test:
    image: postgres:latest
    container_name: ${project_name}_postgres_test
    environment:
      POSTGRES_USER: $dev_db_username
      POSTGRES_PASSWORD: $dev_db_password
      POSTGRES_DB: $test_db_name
    ports:
      - "5433:5432"
EOL

# Print a message with the generated Docker Compose file name
echo "Docker Compose file '$output_file' has been generated."
