require 'logger'

require_relative './schema'
require_relative './models'
require_relative './graphql_schema'
require_relative './factories'

ActiveRecord::Base.logger = GraphQL::Cache.logger
AR::Factories.bootstrap
