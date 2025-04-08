# Search Analytics

A Ruby on Rails application that tracks user search behavior and provides analytics on search patterns. The application implements a "pyramid problem" solution to handle rapid typing sequences and backspaces in search inputs.

## Features

- Real-time search event tracking
- Background job processing for search sequences
- Analytics dashboard showing:
  - Top 20 overall searches
  - Top 10 searches in the last 24 hours
  - Recent individual searches (last hour)
- Handles backspace sequences and rapid typing
- Uses Turbo Streams for real-time updates

## Technical Stack

- Ruby 3.3.3
- Rails 7.1.2
- PostgreSQL
- Redis (for background jobs)
- TailwindCSS
- Turbo & Stimulus.js

## Prerequisites

- PostgreSQL
- Redis
- Ruby 3.x
- Node.js & Yarn

## Setup

1. Clone the repository:
```bash
git clone [repository-url]
cd search_analytics
```

2. Set up environment variables:
```bash
touch .env
```

Edit `.env` with your database credentials:
```
SEARCH_ANALYTICS_DATABASE_HOST=localhost
SEARCH_ANALYTICS_DATABASE_USERNAME=your_username
SEARCH_ANALYTICS_DATABASE_PASSWORD=your_password
SEARCH_ANALYTICS_DATABASE_PORT=5432
REDIS_URL=redis://localhost:6379
```

3. Install dependencies:
```bash
bundle install
yarn install
```

4. Set up the database:
```bash
bin/rails db:create
bin/rails db:migrate
```

## Running the Application

1. Start Redis:
```bash
redis-server
```

2. Start Sidekiq for background jobs:
```bash
bundle exec sidekiq
```

3. Start the Rails server:
```bash
bin/dev
```

4. Visit `http://localhost:3000` in your browser

## Running Tests

```bash
bundle exec rspec --format documentation
```

## How It Works

1. **Search Events**: Every keystroke in the search input creates a `SearchEvent` record
2. **Background Processing**: The `ProcessSearchEventsJob` analyzes sequences of search events
3. **Query Analysis**: The job identifies final queries by looking for:
   - Pauses in typing
   - Backspace sequences
   - Final state of search sequences

4. **Analytics**: The system tracks:
   - Overall popular searches
   - Daily trending searches
   - Individual user search patterns

## API Endpoints

- `GET /` - Main search interface
- `POST /searches` - Create search events
- `GET /analytics` - View search analytics

## Development Guidelines

- Run tests before submitting PRs
- Ensure background jobs are running for local testing
- Use TailwindCSS for styling
- Follow Ruby style guide

## Production Considerations

- Configure proper Redis settings
- Set up proper database indexes
- Consider IP anonymization
- Scale background workers as needed
- Monitor job queues

## License
This project is [MIT](./LICENSE) licensed.
