require 'graphql/cache/version'
require 'graphql/cache/middleware'
require 'graphql/cache/field'

module GraphQL
  module Cache
    ConfigurationError = Class.new(StandardError)

    @@expiry = 5400 # 90 minutes
    def self.expiry; @@expiry; end
    def self.expiry=(obj); @@expiry=obj; end

    @@force = false
    def self.force; @@force; end
    def self.force=(obj); @@force=obj; end

    @@namespace = self.name
    def self.namespace; @@namespace; end
    def self.namespace=(obj); @@namespace=obj; end

    @@cache = nil
    def self.cache; @@cache; end
    def self.cache=(obj); @@cache=obj; end

    @@logger = nil
    def self.logger; @@logger; end
    def self.logger=(obj); @@logger=obj; end

    @@log_level = nil
    def self.log_level; @@log_level; end
    def self.log_level=(obj); @@log_level=obj; @@logger.try(:level=, obj); end

    def self.configure
      yield self
    end

    def self.fetch(key, config: {}, &block)
      return block.call unless config[:cache]

      cached = cache.read(key)

      if cached.nil?
        logger.debug "Cache miss: (#{key})"
        marshal_to_cache(key, config, &block)
      else
        logger.debug "Cache hit: (#{key})"
        marshal_from_cache(cached, config)
      end
    end

    def self.marshal_to_cache(key, config, &block)
      raw = block.call

      marshaled = case raw.class.name
                  when 'Array'
                    raw.map(&:object)
                  when 'GraphQL::Relay::RelationConnection'
                    raw.nodes
                  else
                    raw.try(:object) || raw
                  end

      cache.write(key, marshaled, expires_in: config[:expiry] || GraphQL::Cache.expiry)
      raw
    end

    def self.marshal_from_cache(cached, config = {})
      case cached.class.name
      when 'Array'
        cached.map do |raw|
          config[:field_definition].type.unwrap.graphql_definition.metadata[:type_class].new(
            raw,
            config[:query_context]
          )
        end
      when 'ActiveRecord::Associations::CollectionProxy'
        GraphQL::Relay::RelationConnection.new(
          cached,
          config[:field_args],
          field:   config[:query_context].field,
          parent:  config[:parent_object].object,
          context: config[:query_context]
        )
      else
        klass = config[:field_definition].type.unwrap.graphql_definition.metadata[:type_class]
        if klass
          new(
            cached,
            config[:query_context]
          )
        else
          cached
        end
      end
    end
  end
end

require 'graphql/cache/rails' if defined?(::Rails::Engine)
