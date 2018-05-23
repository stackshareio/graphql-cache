# frozen_string_literal: true

require 'graphql/cache/version'
require 'graphql/cache/middleware'
require 'graphql/cache/field'
require 'graphql/cache/marshal'

module GraphQL
  module Cache
    class << self
      # An object that must conform to the same API as ActiveSupport::Cache::Store
      # @return [Object] Defaults to `Rails.cache` in a Rails environment
      attr_accessor :cache

      # Global default cache key expiration time in seconds.
      # @return [Integer] Default: 5400 (90 minutes)
      attr_accessor :expiry

      # When truthy, override all caching (force evalutaion of resolvers)
      # @return [Boolean] Default: false
      attr_accessor :force

      # Logger instance to use when logging cache hits/misses.
      # @return [Logger]
      attr_accessor :logger

      # Global namespace for keys
      # @return [String] Default: "GraphQL::Cache"
      attr_accessor :namespace

      # Provides for initializer syntax
      #
      # ```
      # GraphQL::Cache.configure do |c|
      #   c.namespace = 'MyNamespace'
      # end
      # ```
      def configure
        yield self
      end
    end

    # Default configuration
    @expiry    = 5400
    @force     = false
    @namespace = 'GraphQL::Cache'

    # Fetches/writes a value for `key` from the cache
    #
    # Always evaluates the block unless config[:metadata][:cache] is truthy
    #
    # @param key [String] the cache key to attempt to fetch
    # @param config [Hash] a hash of middleware config values used to marshal cache data
    # @option config [Hash] :metadata The metadata collected from the field definition
    # @return [Object]
    def self.fetch(key, config: {}, &block)
      return block.call unless config[:metadata][:cache]

      Marshal[key].read(config, &block)
    end
  end
end

require 'graphql/cache/rails' if defined?(::Rails::Engine)
