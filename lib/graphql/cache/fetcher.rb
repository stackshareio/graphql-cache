module GraphQL
  module Cache
    class Fetcher
      def instrument(type, field)
        return field unless field.metadata[:cache]

        cached_resolve_proc = cached_resolve(type, field)

        # Return a copy of `field`, with the new resolve proc
        field.redefine { resolve(cached_resolve_proc) }
      end

      # @private
      def cache_key(obj, args, type, field)
        Key.new(obj, args, type, field).to_s
      end

      # @private
      def cached_resolve(type, field)
        old_resolve_proc = field.resolve_proc

        lambda do |obj, args, ctx|
          key = cache_key(obj, args, type, field)

          Marshal[key].read(field.metadata[:cache], force: ctx[:force_cache]) do
            old_resolve_proc.call(obj, args, ctx)
          end
        end
      end
    end
  end
end
