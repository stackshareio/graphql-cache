# frozen_string_literal: true

module GraphQL
  module Cache
    if defined?(::Rails)
      # Railtie integration used to default {GraphQL::Cache.cache}
      # and {GraphQL::Cache.logger} when in a Rails environment.
      class Rails < ::Rails::Engine
        config.after_initialize do
          # default values for cache and logger in Rails if not set already
          GraphQL::Cache.cache  = ::Rails.cache unless GraphQL::Cache.cache
          GraphQL::Cache.logger = ::Rails.logger unless GraphQL::Cache.logger
        end
      end
    end
  end
end
