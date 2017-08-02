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
    # Overrides `fetch` so that we can automatically
    # (immediately) expire if we are in development, without
    # the need for any one class to carry expirey data.
    # --
    def fetch(key, **opts)
      return yield if opts[:expires_in] == 0.minutes
      super(key, **opts) do
        yield
      end
    end
  end
end
