require 'graphql'

module GraphQL
  module Cache
    class Field < ::GraphQL::Schema::Field
      # Override #initialize to take a new argument:
      def initialize(
        *args,
        cache: false,
        **kwargs,
        &block
      )
        @cache_config = if cache.is_a? Hash
                          cache
                        else
                          { cache: cache }
                        end
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
