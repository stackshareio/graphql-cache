# frozen_string_literal: true

module GraphQL
  module Cache
    class Middleware
      attr_accessor :parent_type, :parent_object, :object, :cache,
        :field_definition, :field_args, :query_context,

      def self.call(*args)
        new(*args).call
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

      def call(&block)
        return yield unless field_definition.metadata[:cache_config]&[:cache]

        GraphQL::Cache.fetch(cache_key, &block)

        raw = cache.read(cache_key)

        yielded = if raw.nil?
                    it = yield
                    cache.write(Marshal.new(it).to_cache)
                    it
                  else
                    Marshal.new(raw).from_cache
                  end


        raw_from_cache = Rails.cache.fetch(key, expires_in: expiry, force: force) do
          puts "Cache Miss: #{key}"
          @raw = yield

          case @raw.class.name
          when 'Array'
            @raw.map(&:object)
          when 'GraphQL::Relay::RelationConnection'
            @raw.nodes
          else
            @raw.object
          end
        end

        case raw_from_cache.class.name
        when 'Array'
          raw_from_cache.map do |raw|
            type_class.new(raw, query_context)
          end
        when 'ActiveRecord::Associations::CollectionProxy'
          GraphQL::Relay::RelationConnection.new(
            raw_from_cache,
            field_args,
            field: query_context.field,
            parent: parent_object.object,
            context: query_context
          )
        else
          type_class.new(raw_from_cache, query_context)
        end
      end

      def cache_key
        @cache_key ||= [
          GraphQL::Cache.cache_prefix,
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

      def type_class
        field_definition.type.unwrap.graphql_definition.metadata[:type_class]
      end
    end
  end
end
