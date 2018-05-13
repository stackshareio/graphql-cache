
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql/cache/version"

Gem::Specification.new do |s|
  s.name          = "graphql-cache"
  s.version       = GraphQL::Cache::VERSION
  s.authors       = ["Michael Kelly"]
  s.email         = ["michaelkelly322@gmail.com"]

  s.summary       = %q{Caching middleware for graphql-ruby}
  s.description   = %q{Provides middleware field-level caching for graphql-ruby}
  s.homepage      = "https://github.com/Leanstack/graphql-cache"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.2.0" # bc graphql-ruby requires >= 2.2.0

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "codeclimate-test-reporter"

  s.add_dependency 'graphql', '~> 1.8.0.pre10'
end
