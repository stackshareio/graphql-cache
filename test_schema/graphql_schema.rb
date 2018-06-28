class BaseType < GraphQL::Schema::Object
  field_class GraphQL::Cache::Field
end

class CustomerType < BaseType
  field :display_name, String, null: false
  field :email, String, null: false
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
end
