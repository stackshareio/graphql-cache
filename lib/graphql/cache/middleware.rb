# frozen_string_literal: true

module GraphQL
  module Cache
    # graphql-ruby middleware to wrap resolvers for caching
    class Middleware
      attr_accessor :parent_type, :parent_object, :object, :cache,
                    :field_definition, :field_args, :query_context

      # Called by graphql-ruby during middleware processing
      def self.call(*args, &block)
        new(*args).call(&block)
      end

      def initialize(parent_type,
                     parent_object,
                     field_definition,
                     field_args,
                     query_context)
        self.parent_type      = parent_type
        self.parent_object    = parent_object
        self.field_definition = field_definition
        self.field_args       = field_args
        self.query_context    = query_context
        self.cache            = ::GraphQL::Cache.cache

        return unless parent_object

        self.object = parent_object.nodes if parent_object.respond_to? :nodes
        self.object = parent_object.object if parent_object.respond_to? :object
      end

      # @private
      def cache_config
        {
          parent_type:      parent_type,
          parent_object:    parent_object,
          field_definition: field_definition,
          field_args:       field_args,
          query_context:    query_context,
          object:           object
        }.merge metadata_hash
      end

      # @private
      def metadata_hash
        {
          metadata: {
            cache: field_definition.metadata[:cache]
          }
        }
      end

      # The primary caching entry point
      #
      # @return [Object]
      def call(&block)
        GraphQL::Cache.fetch(
          cache_key,
          config: cache_config,
          &block
        )
      end

      # @private
      def cache_key
        @cache_key ||= [
          GraphQL::Cache.namespace,
          object_key,
          field_definition.name,
          field_args.keys
        ].flatten
      end

      # @private
      def object_key
        return nil unless object

        "#{object.class.name}:#{id_from_object}"
      end

      # @private
      def id_from_object
        return object.id if object.respond_to? :id
        return object.fetch(:id, nil) if object.respond_to? :fetch
        return object.fetch('id', nil) if object.respond_to? :fetch
      end
    end
  end
end
