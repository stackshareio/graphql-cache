# frozen_string_literal: true

module GraphQL
  module Cache
    class FieldExtension < GraphQL::Schema::FieldExtension
      def apply
        field.instance_variable_set(:@__cache_config, options.present? ? options : true)
      end

      def resolve(object:, arguments:, **rest, &block)
        GraphQL::Cache::Resolver.new(field.owner, field)
                                .call(object, arguments, rest[:context], &block)
      end
    end
  end
end
