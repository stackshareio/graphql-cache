require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Middleware do
      let(:query) do
        %Q{
          {
            ints
          }
        }
      end
      let(:result) do
        GraphQL::Query.new(TestSchema, query, {}).result
      end

      context 'when cache is cold' do
        it 'should return value from resolver' do
          expect(result['data']['ints']).to eq [1, 2]
        end
      end

      context 'when cache is warm' do
        let(:key) { '["GraphQL::Cache", nil, "ints"]' }
        let(:document) { [3,2,1] }

        before do
          cache.write(key, document)
        end

        it 'should return value from cache' do
          expect(result['data']['ints']).to eq [3, 2, 1]
        end
      end
    end
  end
end
