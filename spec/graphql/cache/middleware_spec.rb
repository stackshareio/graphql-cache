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

      context 'when field is not cached' do
        let(:query) do
          %Q{
            {
              anId
            }
          }
        end

        it 'should not marshal anything' do
          expect_any_instance_of(Marshal).to_not receive(:read)
          expect(result['data']['anId']).to eq '123'
        end
      end

      context 'when custom expiry provided' do
        let(:query) do
          %Q{
            {
              expiryInt
            }
          }
        end

        it 'should propgate to cache write' do
          expect(cache).to receive(:write).with('["GraphQL::Cache", nil, "expiryInt"]', 12345, expires_in: 10800)
          result
        end
      end
    end
  end
end
