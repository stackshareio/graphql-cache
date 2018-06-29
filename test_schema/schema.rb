require 'sequel'

DB = Sequel.sqlite(logger: GraphQL::Cache.logger)

DB.create_table :customers do
  primary_key :id
  String :display_name
  String :email
end

DB.create_table :orders do
  primary_key :id
  Integer :customer_id
  Integer :number
  Integer :total_price_cents
end
