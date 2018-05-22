# frozen_string_literal: true

require 'gemer'

require 'graphql/cache/version'
require 'graphql/cache/middleware'
require 'graphql/cache/field'
require 'graphql/cache/marshal'

module GraphQL
  module Cache
    include Gemer::Configurable

    setup_config do |c|
      c.attr :cache
      c.attr :expiry, 5400
      c.attr :force, false, in: [true, false]
      c.attr :logger
      c.attr :namespace, 'GraphQL::Cache'
    end

    # Fetches/writes a value for +key+ from the cache
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
