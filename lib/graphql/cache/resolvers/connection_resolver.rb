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
          if force_cache || (cache = read).nil?
            define_relation_cache(resolve_proc.call, args, field, parent: parent, context: context)
          else
            use(cache, args, field, parent: parent, context: context)
          end
        end

        private

        def define_relation_cache(nodes, args, field, **kwargs)
          if nodes.is_a?(GraphQL::Relay::RelationConnection)
            # inject cached logic into the relation connection
            # works with non Interpreter mode
            nodes
          else
            # nodes are Array or ActiveRecord relation
            wrap_to_connection(nodes, args, field, kwargs)
          end.extend(RelationConnectionOverload.new(method(:write)))
        end

        def use(cache, args, field, **kwargs)
          nodes, paged_nodes = parse(cache)

          wrap_to_connection(nodes, args, field, kwargs).tap do |conn|
            # restore cached paged_nodes (works for AR relations)
            conn.instance_variable_set(:@paged_nodes, paged_nodes) if paged_nodes
          end
        end

        def wrap_to_connection(nodes, args, field, **kwargs)
          GraphQL::Relay::BaseConnection.connection_for_nodes(nodes).new(
            nodes,
            args,
            field: field,
            parent: kwargs[:parent],
            context: kwargs[:context]
          )
        end

        def parse(cache)
          return [cache, nil] unless cache.is_a?(NodesCache)

          [cache.nodes, cache.paged_nodes]
        end
      end
    end
  end
end
