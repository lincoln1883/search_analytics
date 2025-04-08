redis_url = ENV.fetch('REDIS_URL')

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    network_timeout: 5,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    network_timeout: 5,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end