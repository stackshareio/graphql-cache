require 'graphql'

module GraphQL
  module Cache
    # Custom field class implementation to allow for
    # cache config keyword parameters
    class Field < ::GraphQL::Schema::Field
      # Override #initialize to take a new argument:
      def initialize(
        *args,
        cache: false,
        **kwargs,
        &block
      )
        @cache_config = cache
        super(*args, **kwargs, &block)
      end

      def to_graphql
        field_defn = super # Returns a GraphQL::Field
        field_defn.metadata[:cache] = @cache_config
        field_defn
      end
    end
  end
end
