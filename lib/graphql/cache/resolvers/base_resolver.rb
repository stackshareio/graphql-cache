# frozen_string_literal: true

module GraphQL
  module Cache
    module Resolvers
      class BaseResolver
        def initialize(resolve_proc, key, metadata)
          @resolve_proc = resolve_proc
          @key = key
          @metadata = metadata
        end

        def call(*args)
          raise NotImplementedError
        end

        private

        attr_reader :resolve_proc, :key, :metadata

        def read
          Marshal[key].read
        end

        def write(&block)
          Marshal[key].write(metadata, &block)
        end
      end
    end
  end
end
