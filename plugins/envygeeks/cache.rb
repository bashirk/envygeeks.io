# Frozen-String-Literal: true
# Copyright 2017 Jordon Bedwell - MIT License
# Encoding: UTF-8

require "active_support/cache"

module EnvyGeeks
  class Cache < ActiveSupport::Cache::FileStore

    # --
    # @return [<EnvyGeeks::Cache>] the cache
    # Overrides the default method so that we can simply
    #   pass in the name of the directory we want to store
    #   cache files inside of
    # @see https://goo.gl/3G35gw
    # --
    def initialize(dir)
      super(EnvyGeeks.cache_dir.join(dir))
    end

    # --
    # @param key [String,Symbol] the cache key.
    # Overrides `fetch` so that we can automatically
    #   (immediately) expire if we are in development, without
    #   the need for any one class to carry expirey data.
    # @return [<Any>] the cached value.
    # --
    def fetch(key, **opts)
      opts[:expires_in] = expires_in unless opts.key?(:expires_in)
      return yield if opts[:expires_in] == 0.minutes
      super(key, **opts) do
        yield
      end
    end

    # --
    # @return [ActiveSupport::Duration] the time.
    # Tells you how long until we plan to expire something
    #   In production this is always set to 0 minutes, in dev
    #   it's set to around 6 minutes, this way your sites
    #   don't build slow when you are working.
    # --
    private
    def expires_in
      (Jekyll.env == "development" ? 24 : 0).minutes
    end
  end
end
