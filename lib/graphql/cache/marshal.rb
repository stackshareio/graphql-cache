# frozen_string_literal: true

require 'graphql/cache/builder'

module GraphQL
  module Cache
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

      def write(config, &block)
        resolved = block.call
        expiry = config[:expiry] || GraphQL::Cache.expiry

        document = Builder[resolved].deconstruct

        cache.write(key, document, expires_in: expiry)
        resolved
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
