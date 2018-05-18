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

    def self.fetch(key, config: {}, &block)
      return block.call unless config[:metadata][:cache]

      Marshal[key].read(config, &block)
    end
  end
end

require 'graphql/cache/rails' if defined?(::Rails::Engine)
