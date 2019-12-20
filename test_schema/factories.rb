class Factories
  def initialize(order:, customer:)
    @order_class = order
    @customer_class = customer
  end

  def bootstrap
    customer = customer_class.create(
      display_name: 'Michael',
      email: 'michael@example.com'
    )

    order_class.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
    order_class.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
    order_class.create(customer_id: customer.id, number: new_num, total_price_cents: 1399)
  end

  def new_num
    order_class.count + 1000
  end

  private

  attr_reader :order_class, :customer_class
end
