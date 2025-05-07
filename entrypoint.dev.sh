#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
until nc -z -v -w30 db 5432
do
  echo "Waiting for database connection..."
  sleep 5
done

# Create database if it doesn't exist
bundle exec rails db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 