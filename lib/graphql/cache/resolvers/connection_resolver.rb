# frozen_string_literal: true

module GraphQL
  module Cache
    module Resolvers
      # Pass cache write method into GraphQL::Relay::BaseConnection
      # and wrap them original Connection methods
      class ConnectionResolver < BaseResolver
        class ConnectionCache < Module
          module WrappedMethods
            def paged_nodes
              cache_write = instance_variable_get(:@__cache_write)

              cache_write.call { super }
            end
          end

          def initialize(write)
            @write = write
          end

          def extended(base)
            base.extend(WrappedMethods)
            base.instance_variable_set(:@__cache_write, @write)
          end
        end

        def call(args:, field:, parent:, context:, force_cache:)
          if force_cache || (cached = read).nil?
            define_connection_cache(resolve_proc.call)
          else
            wrap_connection(cached, args, field, parent: parent, context: context)
          end
        end

        private

        def wrap_connection(value, args, field, **kwargs)
          GraphQL::Relay::BaseConnection.connection_for_nodes(value).new(
            value,
            args,
            field: field,
            parent: kwargs[:parent],
            context: kwargs[:context]
          )
        end

        def define_connection_cache(connection)
          connection.extend(ConnectionCache.new(method(:write)))
        end
      end
    end
  end
end
