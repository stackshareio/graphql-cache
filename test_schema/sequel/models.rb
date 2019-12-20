class Order < Sequel::Model
  one_to_one :customer
end

class Customer < Sequel::Model
  one_to_many :orders
end
