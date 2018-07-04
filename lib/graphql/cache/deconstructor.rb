module GraphQL
  module Cache
    # GraphQL objects can't be serialized to cache so we have
    # to maintain an abstraction between the raw cache value
    # and the GraphQL expected object. This class exposes methods
    # for deconstructing an object to be stored in cache
    #
    class Deconstructor
      # The raw value to perform actions on. Could be a raw cached value, or
      # a raw GraphQL Field.
      #
      # @return [Object]
      attr_accessor :raw

      # A flag indicating the type of object construction to
      # use when building a new GraphQL object. Can be one of
      # 'array', 'collectionproxy', 'relation'. These values
      # have been chosen because it is easy to use the class
      # names of the possible object types for this purpose.
      #
      # @return [String] 'array' or 'collectionproxy' or 'relation'
      attr_accessor :method

      # Initializer helper that generates a valid `method` string based
      # on `raw.class.name`.
      #
      # @return [Object] A newly initialized GraphQL::Cache::Deconstructor instance
      def self.[](raw)
        build_method = namify(raw.class.name)
        new(raw, build_method)
      end

      # Ruby-only means of "demodularizing" a string
      def self.namify(str)
        str.split('::').last.downcase
      end

      def initialize(raw, method)
        self.raw    = raw
        self.method = method
      end

      # Deconstructs a GraphQL field into a cachable value
      #
      # @return [Object] A value suitable for writing to cache
      def perform
        if %(array collectionproxy).include? method
          deconstruct_array(raw)
        elsif raw.class.ancestors.include? GraphQL::Relay::BaseConnection
          raw.nodes
        else
          deconstruct_object(raw)
        end
      end

      # @private
      def deconstruct_array(raw)
        return [] if raw.empty?

        if raw.first.class.ancestors.include? GraphQL::Schema::Object
          raw.map(&:object)
        else
          raw
        end
      end

      # @private
      def deconstruct_object(raw)
        if raw.respond_to?(:object)
          raw.object
        else
          raw
        end
      end
    end
  end
end

