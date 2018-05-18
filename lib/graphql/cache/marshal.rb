# frozen_string_literal: true

require 'graphql/cache/builder'

module GraphQL
  module Cache
    # Used to marshal data to/from cache on cache hits/misses
    class Marshal
      attr_accessor :key

      def self.[](key)
        new(key)
      end

      def initialize(key)
        self.key = key.to_s
      end

      def read(config, &block)
        cached = cache.read(key)

        if cached.nil?
          logger.debug "Cache miss: (#{key})"
          write config, &block
        else
          logger.debug "Cache hit: (#{key})"
          build cached, config
        end
      end

      def write(config)
        resolved = yield
        document = Builder[resolved].deconstruct

        cache.write(key, document, expires_in: expiry(config))
        resolved
      end

      def expiry(config)
        cache_config = config[:metadata][:cache]

        if cache_config.is_a?(Hash) && cache_config[:expiry]
          config[:metadata][:cache][:expiry]
        else
          GraphQL::Cache.expiry
        end
      end

      def build(cached, config)
        Builder[cached].build(config)
      end

      def cache
        GraphQL::Cache.cache
      end

      def logger
        GraphQL::Cache.logger
      end
    end
  end
end
