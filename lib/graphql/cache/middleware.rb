# frozen_string_literal: true

module GraphQL
  module Cache
    class Middleware
      attr_accessor :parent_type, :parent_object, :object, :cache,
        :field_definition, :field_args, :query_context,

        def self.call(*args, &block)
          new(*args).call(&block)
      end

      def initialize(parent_type, parent_object, field_definition, field_args, query_context)
        self.parent_type      = parent_type
        self.parent_object    = parent_object
        self.field_definition = field_definition
        self.field_args       = field_args
        self.query_context    = query_context
        self.object           = parent_object.try(:object)
        self.cache            = ::GraphQL::Cache.cache
      end

      def cache_config
        {
          parent_type:      parent_type,
          parent_object:    parent_object,
          field_definition: field_definition,
          field_args:       field_args,
          query_context:    query_context,
          object:           object
        }.merge(field_definition.metadata[:cache_config] || {})
      end

      def call(&block)
        GraphQL::Cache.fetch(
          cache_key,
          config: cache_config,
          &block
        )
      end

      def cache_key
        @cache_key ||= [
          GraphQL::Cache.namespace,
          object_key,
          field_definition.name,
          field_args.keys
        ].flatten
      end

      def object_key
        return nil unless object

        id_from_object = object.try(:id) || object.try(:fetch, :id, nil) || object.try(:fetch, 'id', nil)

        "#{object.class.name}:#{id_from_object}"
      end
    end
  end
end
