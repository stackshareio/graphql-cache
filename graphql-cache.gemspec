
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql/cache/version"

Gem::Specification.new do |spec|
  spec.name          = "graphql-cache"
  spec.version       = GraphQL::Cache::VERSION
  spec.authors       = ["Michael Kelly"]
  spec.email         = ["michaelkelly322@gmail.com"]

  spec.summary       = %q{Caching middleware for graphql-ruby}
  spec.description   = %q{Provides middleware field-level caching for graphql-ruby}
  spec.homepage      = "https://github.com/Leanstack/graphql-cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.2.0" # bc graphql-ruby requires >= 2.2.0

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'graphql', '~> 1.8.0.pre10'
end
