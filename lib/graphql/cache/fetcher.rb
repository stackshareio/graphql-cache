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

        cached_resolve_proc = cached_resolve(type, field)

        # Return a copy of `field`, with the new resolve proc
        field.redefine { resolve(cached_resolve_proc) }
      end

      # @private
      def cache_key(obj, args, type, field)
        Key.new(obj, args, type, field).to_s
      end

      # @private
      def cached_resolve(type, field)
        old_resolve_proc = field.resolve_proc

        lambda do |obj, args, ctx|
          key = cache_key(obj, args, type, field)

          value = Marshal[key].read(
            field.metadata[:cache], force: ctx[:force_cache]
          ) do
            old_resolve_proc.call(obj, args, ctx)
          end

          wrap_connections(value, args, field, obj, ctx)
        end
      end

      # @private
      def wrap_connections(value, args, field, obj, ctx)
        # return raw value if field isn't a connection (no need to wrap)
        return value unless field.connection?

        # return cached value if it is already a connection object
        # this occurs when the value is being resolved by GraphQL
        # and not being read from cache
        return value if value.class.ancestors.include?(
          GraphQL::Relay::BaseConnection
        )

        create_connection(value, args, field, obj, ctx)
      end

      # @private
      def create_connection(value, args, field, obj, ctx)
        GraphQL::Relay::BaseConnection.connection_for_nodes(value).new(
          value,
          args,
          field: field,
          parent: obj,
          context: ctx
        )
      end
    end
  end
end
