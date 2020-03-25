require 'spec_helper'

RSpec.describe 'caching scalar fields' do
  let(:query) do
    %Q{
      {
        customer(id: #{customer.id}) {
          orders {
            edges {
              node {
                totalPriceCents
              }
            }
          }
        }
      }
    }
  end

  describe 'ActiveRecord' do
    def execute(query, context = {})
      AR::CacheSchema.execute(query, context: context)
    end

    let(:customer) { AR::Customer.last }

    before do
      customer.orders.delete_all
      customer.orders.create(total_price_cents: 100)# only one order
    end

    it 'calls order total_price_cents only one times' do
      expect_any_instance_of(AR::Order).to receive(:total_price_cents).once.and_call_original
      
      5.times { execute(query) }
    end
  end
end
