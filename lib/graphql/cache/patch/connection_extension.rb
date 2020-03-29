module GraphQL
  module Cache
    module Patch
      module ConnectionExtension
        def after_resolve(value:, object:, arguments:, context:, memo:)
          # in Cached Extension we wrap the original value to the Connection
          # so we do not have to do it againt
          return value if value.is_a?(GraphQL::Relay::BaseConnection)

          super
        end
      end
    end
  end
end

GraphQL::Schema::Field::ConnectionExtension.prepend(
  GraphQL::Cache::Patch::ConnectionExtension
)
