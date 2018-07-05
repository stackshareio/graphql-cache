require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Field do
      let(:cache_config) do
        {
          expiry: 10800
        }
      end

      subject { described_class.new(type: CustomerType, name: :title, cache: cache_config, null: true) }

      describe '#to_graphql' do
        it 'should inject cache config metadata' do
          expect(subject.to_graphql.metadata[:cache]).to eq cache_config
        end
      end
    end
  end
end
