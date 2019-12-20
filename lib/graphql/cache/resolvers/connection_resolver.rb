# frozen_string_literal: true

module GraphQL
  module Cache
    module Resolvers
      class ConnectionResolver < BaseResolver
        NodesCache = Struct.new(:nodes, :paged_nodes)

        # Pass cache write method into GraphQL::Relay::RelationConnection
        class RelationConnectionOverload < Module
          module WrappedMethods
            def paged_nodes
              cache_write = instance_variable_get(:@__cache_write)

              super.tap do |result|
                # save original relation (aka @nodes) and loaded records
                cache_write.call { NodesCache.new(@nodes, result) }
              end
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
            define_relation_cache(resolve_proc.call)
          else
            wrap_connection(cached, args, field, parent: parent, context: context)
          end
        end

        private

        def wrap_connection(cached, args, field, **kwargs)
          nodes, paged_nodes = parse(cached)

          GraphQL::Relay::BaseConnection.connection_for_nodes(nodes).new(
            nodes,
            args,
            field: field,
            parent: kwargs[:parent],
            context: kwargs[:context]
          ).tap do |connection|
            # restore cached paged_nodes
            connection.instance_variable_set(:@paged_nodes, paged_nodes) if paged_nodes
          end
        end

        def define_relation_cache(connection)
          if connection.is_a?(GraphQL::Relay::RelationConnection)
            # inject cached logic into the relation connection
            connection.extend(RelationConnectionOverload.new(method(:write)))
          else
            # cache loaded connection (works for ArrayConnection)
            write { connection }
          end
        end

        def parse(cached)
          return [cached, nil] unless cached.is_a?(NodesCache)

          [cached.nodes, cached.paged_nodes]
        end
      end
    end
  end
end
