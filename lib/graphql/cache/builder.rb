module GraphQL
  module Cache
    class Builder
      attr_accessor :raw, :method, :config

      def self.[](raw)
        build_method = namify(raw.class.name)
        new(raw, build_method)
      end

      def self.namify(str)
        str.split('::').last.downcase
      end

      def initialize(raw, method)
        self.raw    = raw
        self.method = method
      end

      def build(config)
        self.config = config

        return build_array    if method == 'array'
        return build_relation if method == 'collectionproxy' || method == 'relation'
        build_object
      end

      def deconstruct
        case self.class.namify(raw.class.name)
        when 'array'
          deconstruct_array(raw)
        when 'relationconnection'
          raw.nodes
        else
          deconstruct_object(raw)
        end
      end

      def deconstruct_object(raw)
        if raw.respond_to?(:object)
          raw.object
        else
          raw
        end
      end

      def deconstruct_array(raw)
        return [] if raw.empty?

        if raw.first.class.ancestors.include? GraphQL::Schema::Object
          raw.map(&:object)
        else
          raw
        end
      end

      def build_relation
        GraphQL::Relay::RelationConnection.new(
          raw,
          config[:field_args],
          field:   config[:query_context].field,
          parent:  config[:parent_object].object,
          context: config[:query_context]
        )
      end

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
