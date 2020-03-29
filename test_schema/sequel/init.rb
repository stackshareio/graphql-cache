require 'logger'

require_relative './schema'
require_relative './models'
require_relative './graphql_schema'
require_relative '../factories'

Factories.new(order: Order, customer: Customer).bootstrap
DB.loggers = [GraphQL::Cache.logger]
