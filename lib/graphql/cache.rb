require 'graphql/cache/version'
require 'graphql/cache/middleware'
require 'graphql/cache/field'
require 'graphql/cache/marshal'

module GraphQL
  module Cache
    ConfigurationError = Class.new(StandardError)

    @@expiry = 5400 # 90 minutes
    def self.expiry; @@expiry; end
    def self.expiry=(obj); @@expiry=obj; end

    @@force = false
    def self.force; @@force; end
    def self.force=(obj); @@force=obj; end

    @@namespace = self.name
    def self.namespace; @@namespace; end
    def self.namespace=(obj); @@namespace=obj; end

    @@cache = nil
    def self.cache; @@cache; end
    def self.cache=(obj); @@cache=obj; end

    @@logger = nil
    def self.logger; @@logger; end
    def self.logger=(obj); @@logger=obj; end

    def self.configure
      yield self
    end

    def self.fetch(key, config: {}, &block)
      return block.call unless config[:cache]

      Marshal[key].read(config, &block)
    end
  end
end

require 'graphql/cache/rails' if defined?(::Rails::Engine)
