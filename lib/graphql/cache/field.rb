module GraphQL
  module Cache
    class Field < GraphQL::Schema::Field
      # Override #initialize to take a new argument:
      def initialize(
        *args,
        cache: false,
        cache_expiry: GraphQL::Cache.global_expiry,
        **kwargs,
        &block
      )
        @cachabe_config = {
          cache: cache,
          cache_expiry: cache_expiry
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
