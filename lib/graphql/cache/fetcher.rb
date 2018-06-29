module GraphQL
  module Cache
    class Fetcher
      attr_accessor :options

      def initialize(options = {})
        @options = options
      end

      def instrument(type, field)
        if field.metadata[:cache]
          old_resolve_proc = field.resolve_proc

          new_resolve_proc = ->(obj, args, ctx) {

            unless field.metadata[:cache]
              return old_resolve_proc.call(obj, args, ctx)
            end

            Marshal[
              cache_key(obj, args, type, field)
            ].read(
              metadata: {
                cache: field.metadata[:cache]
              }
            ) do
              old_resolve_proc.call(obj, args, ctx)
            end
          }

          # Return a copy of `field`, with a new resolve proc
          field.redefine do
            resolve(new_resolve_proc)
          end
        else
          field
        end
      end

      # @private
      def cache_key(obj, args, type, field)
        [
          GraphQL::Cache.namespace,
          type.name,
          field.name,
          (obj.object ? obj.object.id : nil),
          args.to_h.to_a.flatten
        ].flatten
      end
    end
  end
end
