require 'logger'

require_relative './test_schema/schema'
require_relative './test_schema/models'
require_relative './test_schema/graphql_schema'
require_relative './test_schema/factories'

Factories.bootstrap
DB.loggers = [GraphQL::Cache.logger]
