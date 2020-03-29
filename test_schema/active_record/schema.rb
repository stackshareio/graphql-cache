require 'active_record'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :schema_migrations, force: true

  create_table :customers, force: true do |t|
    t.string :display_name
    t.string :email
  end

  create_table :orders, force: true do |t|
    t.integer :customer_id
    t.integer :number
    t.integer :total_price_cents
  end
end
