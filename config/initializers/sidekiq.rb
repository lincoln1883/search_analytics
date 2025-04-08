# redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') # Default to local Redis DB 1

# Sidekiq.configure_server do |config|
#   config.redis = { url: redis_url, network_timeout: 5 }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: redis_url, network_timeout: 5 }
# end
require 'upstash/redis'

redis = Upstash::Redis.new(
  url: ENV["UPSTASH_REDIS_REST_URL"],
  token: ENV["UPSTASH_REDIS_REST_TOKEN"]
)

Sidekiq.configure_server do |config|
  config.redis = { client: redis }
end

Sidekiq.configure_client do |config|
  config.redis = { client: redis }
end
