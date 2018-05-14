require 'bundler/setup'
require 'pry'

require 'codeclimate-test-reporter'
require 'simplecov'
SimpleCov.start

require 'graphql/cache'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    GraphQL::Cache.cache  = TestCache.new
    GraphQL::Cache.logger = TestLogger.new
  end

  config.include TestMacros
  config.extend  TestMacros::ClassMethods
end
