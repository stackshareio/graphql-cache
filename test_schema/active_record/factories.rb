module AR
  class Factories
    def self.bootstrap
      customer = AR::Customer.create(
        display_name: 'Michael',
        email: 'michael@example.com'
      )

      AR::Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
      AR::Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
      AR::Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
    end

    def self.new_num
      AR::Order.count + 1000
    end
  end
end
