require 'graphql/cache/util/module'

module GraphQL
  module Cache
    module Configuration
      def configure
        yield self
      end

      # global cache expiration time (in seconds)
      mattr_accessor :global_expiry
      @@global_expiry = 5400  # 90 minutes

      # Globally force cache misses on ever field
      mattr_accessor :force
      @@force = false

      # Cache prefix for all GraphQL::Cache keys
      mattr_accessor :cache_prefix
      @@cache_prefix = self.name

      # A caching object that conforms to the Rails cache interface
      mattr_accessor :cache
      @@cache = nil

      # A logger, cause you always need one of those
      mattr_accessor :logger
      @@logger = nil
    end
  end
end
