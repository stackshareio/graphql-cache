module Factories
  def self.bootstrap
    Customer.create(
      display_name: 'Michael',
      email: 'michael@example.com'
    )
  end
end
