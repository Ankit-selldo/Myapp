#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
until nc -z -v -w30 $DATABASE_HOST $DATABASE_PORT
do
  echo "Waiting for database connection..."
  sleep 5
done

# Run database migrations
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 