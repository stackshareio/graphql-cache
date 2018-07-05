module GraphQL
  module Cache
    class Fetcher
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
        Key.new(obj, args, type, field).to_s
      end
    end
  end
end
