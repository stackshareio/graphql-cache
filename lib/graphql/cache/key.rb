module GraphQL
  module Cache
    # Represents a cache key generated from the graphql context
    # provided when initialized
    class Key
      # The resolved parent object (object this resolver method is called on)
      attr_accessor :object

      # Arguments passed during graphql query execution
      attr_accessor :arguments

      # The graphql parent type
      attr_accessor :type

      # The graphql field being resolved
      attr_accessor :field

      # Metadata passed to the cache key on field definition
      attr_accessor :metadata

      # Initializes a new Key with the given graphql query context
      #
      # @param obj [Object] The resolved parent object for a field's resolution
      # @param args [GraphQL::Arguments] The internal graphql-ruby wrapper for field arguments
      # @param type [GraphQL::Schema::Type] The type definition of the parent object
      # @param field [GraphQL::Schema::Field] The field being resolved
      def initialize(obj, args, type, field)
        @object    = obj.object
        @arguments = args
        @type      = type
        @field     = field
        @metadata  = field.metadata[:cache]

        @metadata = { cache: @metadata } unless @metadata.is_a?(Hash)
      end

      # Returns the string representation of this cache key
      # suitable for using as a key when writing to cache
      #
      # The key is constructed with this structure:
      #
      # ```
      # namespace:type:field:arguments:object-id
      # ```
      def to_s
        @to_s ||= [
          GraphQL::Cache.namespace,
          type_clause,
          field_clause,
          arguments_clause,
          object_clause
        ].flatten.compact.join(':')
      end

      # Produces the portion of the key representing the parent object
      def object_clause
        return nil unless object

        "#{object.class.name}:#{object_identifier}"
      end

      # Produces the portion of the key representing the parent type
      def type_clause
        type.name
      end

      # Produces the portion of the key representing the resolving field
      def field_clause
        field.name
      end

      # Produces the portion of the key representing the query arguments
      def arguments_clause
        @arguments_clause ||= arguments.to_h.to_a.flatten
      end

      # @private
      def object_identifier
        case metadata[:key]
        when Symbol
          object.send(metadata[:key])
        when Proc
          metadata[:key].call(object)
        when NilClass
          guess_id
        else
          metadata[:key]
        end
      end

      # @private
      def guess_id
        return object.cache_key_with_version if object.respond_to?(:cache_key_with_version)
        return object.cache_key if object.respond_to?(:cache_key)
        return object.id if object.respond_to?(:id)
        object.object_id
      end
    end
  end
end
