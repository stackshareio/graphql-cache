require 'graphql'

module GraphQL
  module Cache
    # Custom field class implementation to allow for
    # cache config keyword parameters
    class Field < ::GraphQL::Schema::Field
      # Overriden to take a new cache keyword argument
      def initialize(
        *args,
        cache: false,
        **kwargs,
        &block
      )
        @cache_config = cache
        super(*args, **kwargs, &block)
      end

      # Overriden to provide custom cache config to internal definition
      def to_graphql
        field_defn = super # Returns a GraphQL::Field
        field_defn.metadata[:cache] = @cache_config
        field_defn
      end
    end
  end
end
