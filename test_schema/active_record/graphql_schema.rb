require 'benchmark'

module AR
  class BaseType < ::BaseType; end
  class OrderType < ::OrderType; end

  class CustomerType < ::CustomerType; end

  class QueryType < ::QueryType
    def customer(id:)
      AR::Customer.find(id)
    end
  end

  class CacheSchema < ::CacheSchema
    query AR::QueryType
    use GraphQL::Cache

    def self.resolve_type(_type, obj, _ctx)
      "AR::#{obj.class.name}Type"
    end
  end
end
