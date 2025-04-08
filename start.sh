#!/bin/bash
set -e

echo "Running DB migrations..."
bundle exec rails db:migrate

echo "Starting Sidekiq..."
bundle exec sidekiq &

echo "Starting Rails server..."
bundle exec rails server -b 0.0.0.0 -p "${PORT:-3000}"


