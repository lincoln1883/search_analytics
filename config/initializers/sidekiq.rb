redis_url = ENV.fetch('REDIS_URL') do
  if Rails.env.development? || Rails.env.test?
    'redis://localhost:6379/1' # Local fallback
  else
    raise "REDIS_URL environment variable not set!"
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, network_timeout: 5 }
end
