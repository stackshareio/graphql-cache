require 'spec_helper'

def execute(query, context = {})
  CacheSchema.execute(query, context: context)
end

RSpec.describe 'caching connection fields' do
  let(:query) do
    %Q{
      {
        customer(id: #{Customer.last.id}) {
          orders {
            edges {
              node {
                id
              }
            }
          }
        }
      }
    }
  end

  it 'produces the same result on miss or hit' do
    cold_results = execute(query)
    warm_results = execute(query)

    expect(cold_results).to eq warm_results
  end
end
