#!/bin/bash
set -e

echo "Running DB migrations..."
bundle exec rails db:migrate

echo "Starting application processes..."
bundle exec foreman start

