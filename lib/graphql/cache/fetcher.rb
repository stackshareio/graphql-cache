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

          cached_value = Marshal[key].read(
            field.metadata[:cache], force: ctx[:force_cache]
          ) do
            old_resolve_proc.call(obj, args, ctx)
          end

          wrap_connections(cached_value, args, field, obj, ctx)
        end
      end

      # @private
      def wrap_connections(cached_value, args, field, obj, ctx)
        # check for a connection implementation for this cached value
        conn_class = cached_value.class.ancestors.find do |ancestor|
          !connection_for(ancestor.name).nil?
        end

        if conn_class
          create_connection(conn_class, cached_value, args, field, obj, ctx)
        else
          # if we get here, this is not a connection
          # value and should be returned as is
          cached_value
        end
      end

      # @private
      def connection_for(name)
        GraphQL::Relay::BaseConnection::CONNECTION_IMPLEMENTATIONS[name]
      end

      # rubocop:disable Metrics/ParameterLists

      # @private
      def create_connection(conn_class, value, args, field, obj, ctx)
        connection_for(conn_class.name).new(
          value,
          args,
          field: field,
          parent: obj,
          context: ctx
        )
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
