module GraphQL
  module Cache
    # GraphQL objects can't be serialized to cache so we have
    # to maintain an abstraction between the raw cache value
    # and the GraphQL expected object. This class exposes methods
    # for both deconstructing an object to be stored in cache
    # and re-hydrating a GraphQL object from raw cache values
    #
    class Builder
      # The raw value to perform actions on. Could be a raw cached value, or
      # a raw GraphQL Field.
      #
      # @return [Object]
      attr_accessor :raw

      # A flag indicating the type of object construction to
      # use when building a new GraphQL object. Can be one of
      # 'array', 'collectionproxy', 'relation'. These values
      # have been chosen because it is easy to use the class
      # names of the possible object types for this purpose.
      #
      # @return [String] 'array' or 'collectionproxy' or 'relation'
      attr_accessor :method

      # The middleware config hash describing a field's resolution
      #
      # @see GraphQL::Cache::Middleware#initialize
      # @return [Hash]
      attr_accessor :config

      # Initializer helper that generates a valid `method` string based
      # on `raw.class.name`.
      #
      # @return [Object] A newly initialized GraphQL::Cache::Builder instance
      def self.[](raw)
        build_method = namify(raw.class.name)
        new(raw, build_method)
      end

      # Ruby-only means of "demodularizing" a string
      def self.namify(str)
        str.split('::').last.downcase
      end

      def initialize(raw, method)
        self.raw    = raw
        self.method = method
      end

      # Builds a compitable GraphQL object based on the resolution config
      #
      # @return [Object] An object suitable for returning from a GraphQL middlware call
      def build(config)
        self.config = config

        return build_array    if method == 'array'
        return build_relation if method == 'collectionproxy' || method == 'relation'
        build_object
      end

      # Deconstructs a GraphQL field into a cachable value
      #
      # @return [Object] A value suitable for writing to cache
      def deconstruct
        return deconstruct_array(raw) if raw.class == Array
        return raw.nodes if raw.class.ancestors.include? GraphQL::Relay::BaseConnection

        deconstruct_object(raw)
      end

      # @private
      def deconstruct_object(raw)
        if raw.respond_to?(:object)
          raw.object
        else
          raw
        end
      end

      # @private
      def deconstruct_array(raw)
        return [] if raw.empty?

        if raw.first.class.ancestors.include? GraphQL::Schema::Object
          raw.map(&:object)
        else
          raw
        end
      end

      # @private
      def build_relation
        GraphQL::Relay::BaseConnection.connection_for_nodes(raw).new(
          raw,
          config[:field_args],
          field:   config[:query_context].field,
          parent:  config[:parent_object].object,
          context: config[:query_context]
        )
      end

      # @private
      def build_array
        gql_def = config[:field_definition].type.unwrap.graphql_definition

        raw.map do |item|
          if gql_def.kind.name == 'OBJECT'
            config[:field_definition].type.unwrap.graphql_definition.metadata[:type_class].new(
              item,
              config[:query_context]
            )
          else
            item
          end
        end
      end

      # @private
      def build_object
        klass = config[:field_definition].type.unwrap.graphql_definition.metadata[:type_class]
        if klass
          klass.new(
            raw,
            config[:query_context]
          )
        else
          raw
        end
      end
    end
  end
end
