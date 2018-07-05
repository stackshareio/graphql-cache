# frozen_string_literal: true

module TestMacros
  def cache
    GraphQL::Cache.cache
  end

  module ClassMethods
    def self.extended(mod)
      mod.class_eval do
        setup_query
      end
    end

    def setup_query
      let(:query) { GraphQL::Query.new(CacheSchema) }
    end
  end
end
