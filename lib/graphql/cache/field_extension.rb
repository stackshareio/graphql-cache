# frozen_string_literal: true

module GraphQL
  module Cache
    class FieldExtension < GraphQL::Schema::FieldExtension
      def apply
        field.instance_variable_set(:@__cache_config, options.present? ? options : true)
      end

      def resolve(object:, arguments:, **rest)
        if field.connection?
          yield(object, arguments, object: object, arguments: arguments)
        else
          GraphQL::Cache::Resolver.new(field.owner, field)
                                  .call(object, arguments, rest[:context], proc { yield(object, arguments) })
        end
      end

      def after_resolve(value:, memo:, **rest)
        return value unless field.connection?

        arguments = memo[:arguments]
        object = memo[:object]

        GraphQL::Cache::Resolver.new(field.owner, field)
                                .call(object, arguments, rest[:context], proc { value })
      end
    end
  end
end
