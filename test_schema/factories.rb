module Factories
  def self.bootstrap
    customer = Customer.create(
      display_name: 'Michael',
      email: 'michael@example.com'
    )

    Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
    Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
    Order.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
  end

  def self.new_num
    Order.count + 1000
  end
end
