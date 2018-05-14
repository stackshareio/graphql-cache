# frozen_string_literal: true

module TestMacros
  def cache
    GraphQL::Cache.cache
  end

  module ClassMethods
    def self.extended(mod)
      mod.class_eval do
        config
      end
    end

    def document(&block)
      let(:document, &block)
    end

    def key(&block)
      let(:key, &block)
    end

    def config(opts={})
      let(:config) do
        {
          cache:            opts[:cache] || (opts[:cache].nil? ? true : false),
          parent_type:      opts[:parent_type] || TestSchema.types['Test'],
          parent_object:    opts[:parent_object],
          field_definition: opts[:field_definition] || TestSchema.types['Test'].fields['anId'],
          field_args:       opts[:field_args],
          query_context:    opts[:query_context] || {},
          object:           opts[:object]
        }
      end
    end
  end
end
