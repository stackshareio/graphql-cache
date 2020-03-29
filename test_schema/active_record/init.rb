require 'logger'

require_relative './schema'
require_relative './models'
require_relative './graphql_schema'
require_relative '../factories'

ActiveRecord::Base.logger = GraphQL::Cache.logger
Factories.new(order: AR::Order, customer: AR::Customer).bootstrap

