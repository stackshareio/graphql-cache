module GraphQL
  module Cache
    class Fetcher
      attr_accessor :options

      def initialize(options = {})
        @options = options
      end

      def instrument(type, field)
        old_resolve_proc = field.resolve_proc

        new_resolve_proc = lambda do |obj, args, ctx|
          unless field.metadata[:cache]
            return old_resolve_proc.call(obj, args, ctx)
          end

          key = cache_key(obj, args, type, field)

          Marshal[key].read(field.metadata[:cache]) do
            old_resolve_proc.call(obj, args, ctx)
          end
        end

        # Return a copy of `field`, with the new resolve proc
        field.redefine { resolve(new_resolve_proc) }
      end

      # @private
      def cache_key(obj, args, type, field)
        object = obj.object
        [
          GraphQL::Cache.namespace,
          (object ? "#{object.class.name}:#{object.id}" : nil),
          type.name,
          field.name,
          args.to_h.to_a.flatten
        ].flatten
      end
    end
  end
end
