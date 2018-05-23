# frozen_string_literal: true

require 'graphql/cache/builder'

module GraphQL
  module Cache
    # Used to marshal cache fetches into either writes or reads
    class Marshal
      # The cache key to marshal around
      #
      # @return [String] The cache key
      attr_accessor :key

      # Initializer helper to allow syntax like
      # `Marshal[key].read(config, &block)`
      #
      # @return [GraphQL::Cache::Marshal]
      def self.[](key)
        new(key)
      end

      # Initialize a new instance of {GraphQL::Cache::Marshal}
      def initialize(key)
        self.key = key.to_s
      end

      # Read a value from cache if it exists and re-hydrate it or
      # execute the block and write it's result to cache
      #
      # @param config [Hash] The middleware resolution config
      # @return [Object]
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

      # Executes the resolution block and writes the result to cache
      #
      # @see GraphQL::Cache::Builder#deconstruct
      # @param config [Hash] The middleware resolution config hash
      def write(config)
        resolved = yield
        document = Builder[resolved].deconstruct

        cache.write(key, document, expires_in: expiry(config))
        resolved
      end

      # @private
      def expiry(config)
        cache_config = config[:metadata][:cache]

        if cache_config.is_a?(Hash) && cache_config[:expiry]
          config[:metadata][:cache][:expiry]
        else
          GraphQL::Cache.expiry
        end
      end

      # Uses {GraphQL::Cache::Builder} to build a valid GraphQL object
      # from a cached value
      #
      # @return [Object] An object suitable to return from a GraphQL middleware
      def build(cached, config)
        Builder[cached].build(config)
      end

      # @private
      def cache
        GraphQL::Cache.cache
      end

      # @private
      def logger
        GraphQL::Cache.logger
      end
    end
  end
end
