class BaseType < GraphQL::Schema::Object
  field_class GraphQL::Cache::Field
end

class OrderType < BaseType
  field :id, Int, null: false
  field :number, Int, null: true
  field :total_price_cents, Int, null: true
end

class CustomerType < BaseType
  field :display_name, String, null: false
  field :email, String, null: false
  field :orders, OrderType.connection_type, null: false, cache: true
end

class QueryType < BaseType
  field :customer, CustomerType, null: true, cache: true do
    argument :id, ID, 'Unique Identifier for querying a specific user', required: true
  end

  def customer(id:)
    Customer[id]
  end
end

class Schema < GraphQL::Schema
  query QueryType

  middleware GraphQL::Cache::Middleware

  def self.resolve_type(_type, obj, _ctx)
    "#{obj.class.name}Type"
  end
end
