module GraphQL
  module Cache
    class Field < GraphQL::Schema::Field
      # Override #initialize to take a new argument:
      def initialize(
        *args,
        cache: false,
        expiry: nil,
        **kwargs,
        &block
      )
        @cache_config = {
          cache: cache,
          expiry: expiry
        }
        super(*args, **kwargs, &block)
      end

      def to_graphql
        field_defn = super # Returns a GraphQL::Field
        field_defn.metadata[:cache_config] = @cache_config
        field_defn
      end
    end
  end
end
