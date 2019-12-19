# frozen_string_literal: true

module GraphQL
  module Cache
    module Resolvers
      class ScalarResolver < BaseResolver
        def call(force_cache:)
          return write if force_cache

          cached = read

          cached.nil? ? write { resolve_proc.call } : cached
        end
      end
    end
  end
end
