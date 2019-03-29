# frozen_string_literal: true

require 'graphql/cache/resolver'

module GraphQL
  module Cache
    # Represents the "instrumenter" passed to GraphQL::Schema#instrument
    # when the plugin in initialized (i.e. `use GraphQL::Cache`)
    class Fetcher
      # Redefines the given field's resolve proc to use our
      # custom cache wrapping resolver proc. Called from
      # graphql-ruby internals. This is the "instrumenter"
      # entrypoint.
      #
      # @param type [GraphQL::Schema::Object] graphql-ruby passes the defined type for the field being instrumented
      # @param field [GraphQL::Schema::Field] graphql-ruby passes the field definition to be re-defined
      # @return [GraphQL::Schema::Field]
      def instrument(type, field)
        return field unless field.metadata[:cache]

        field.redefine { resolve(GraphQL::Cache::Resolver.new(type, field)) }
      end
    end
  end
end
