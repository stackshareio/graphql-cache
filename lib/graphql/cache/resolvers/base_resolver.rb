# frozen_string_literal: true

module GraphQL
  module Cache
    module Resolvers
      class BaseResolver
        def initialize(resolve_proc, key, cache_config)
          @resolve_proc = resolve_proc
          @key = key
          @cache_config = cache_config
        end

        def call(*args)
          raise NotImplementedError
        end

        private

        attr_reader :resolve_proc, :key, :cache_config

        def read
          Marshal[key].read
        end

        def write(&block)
          Marshal[key].write(cache_config, &block)
        end
      end
    end
  end
end
