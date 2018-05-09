require 'graphql/cache/version'
require 'graphql/cache/configuration'
require 'graphql/cache/middleware'

module GraphQL
  module Cache
    extend Configuration

    ConfigurationError = Class.new(StandardError)
  end
end

require 'graphql/cache/rails' if defined?(::Rails::Engine)
