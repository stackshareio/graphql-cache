module AR
  class Order < ActiveRecord::Base
    belongs_to :customer
  end

  class Customer < ActiveRecord::Base
    has_many :orders
  end
end
