require "sidekiq"

url = ENV["REDIS_URL"]

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url }
  end
end

$import_pool = ConnectionPool.new(size: 1, timeout: 43_200) { :pool_instance }
