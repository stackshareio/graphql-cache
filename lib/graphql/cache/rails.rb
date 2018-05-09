# frozen_string_literal: true

module GraphQL
  module Cache
    class Rails < ::Rails::Engine
      config.after_initialize do
        # default values for cache and logger in Rails if not set in initializer
        GraphQL::Cache.cache  = ::Rails.cache unless GraphQL::Cache.cache
        GraphQL::Cache.logger = ::Rails.logger unless GraphQL::Cache.logger
      end
    end if defined?(::Rails)
  end
end
