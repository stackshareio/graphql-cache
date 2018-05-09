# Graphql Cache

  [![Build Status](https://travis-ci.org/Leanstack/graphql-cache.svg?branch=master)](https://travis-ci.org/Leanstack/graphql-cache)

  GraphQL Cache is a custom middleware for graphql-ruby providing field-level caching

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-cache'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-cache

## Setup

  1. Add `middleware GraphQL::Cache::Middleware` to your schema
  2. Add `field_class GraphQL::Cache::Field` to your base object type

## Usage

Any object, list, or connection field can be cached by simply adding `cache: true` to the field definition:

```ruby
field :calculated_field, Int, cache: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Leanstack/graphql-cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphql::Cache project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Leanstack/graphql-cache/blob/master/CODE_OF_CONDUCT.md).
