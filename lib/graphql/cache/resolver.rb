# frozen_string_literal: true

module GraphQL
  module Cache
    # Represents the caching resolver that wraps the existing resolver proc
    class Resolver
      attr_accessor :type

      attr_accessor :field

      attr_accessor :orig_resolve_proc

      def initialize(type, field)
        @type  = type
        @field = field
      end

      def call(obj, args, ctx)
        @orig_resolve_proc = field.resolve_proc

        key = cache_key(obj, args, ctx)

        value = Marshal[key].read(
          field.metadata[:cache], force: ctx[:force_cache]
        ) do
          @orig_resolve_proc.call(obj, args, ctx)
        end

        wrap_connections(value, args, parent: obj, context: ctx)
      end

      protected

      # @private
      def cache_key(obj, args, ctx)
        Key.new(obj, args, type, field, ctx).to_s
      end

      # @private
      def wrap_connections(value, args, **kwargs)
        # return raw value if field isn't a connection (no need to wrap)
        return value unless field.connection?

        # return cached value if it is already a connection object
        # this occurs when the value is being resolved by GraphQL
        # and not being read from cache
        return value if value.class.ancestors.include?(
          GraphQL::Relay::BaseConnection
        )

        create_connection(value, args, **kwargs)
      end

      # @private
      def create_connection(value, args, **kwargs)
        GraphQL::Relay::BaseConnection.connection_for_nodes(value).new(
          value,
          args,
          field: field,
          parent: kwargs[:parent],
          context: kwargs[:context]
        )
      end
    end
  end
end
