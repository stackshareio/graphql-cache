require 'spec_helper'

RSpec.describe GraphQL::Cache do
  let(:cache) { GraphQL::Cache.cache }

  context 'configuration' do
    subject { described_class }

    it { should respond_to :cache }
    it { should respond_to :cache= }

    it { should respond_to :logger }
    it { should respond_to :logger= }

    it { should respond_to :expiry }
    it { should respond_to :expiry= }

    it { should respond_to :expiry }
    it { should respond_to :expiry= }

    it { should respond_to :force }
    it { should respond_to :force= }

    it { should respond_to :namespace }
    it { should respond_to :namespace= }

    describe '#fetch' do
      let(:key)   { 'key' }
      let(:value) { 'foo' }
      let(:config) do
        {
          cache:            true,
          parent_type:      TestSchema.types['Test'],
          parent_object:    nil,
          field_definition: TestSchema.types['Test'].fields['anId'],
          field_args:       nil,
          query_context:    nil,
          object:           nil
        }
      end

      subject do
        described_class.fetch(key, config: config) { value }
      end

      context 'config->cache is not set' do
        let(:config) { Hash.new }

        it 'should return resolver result' do
          expect(subject).to eq 'foo'
        end
      end

      context 'key is not in cache' do
        it 'should set cache key' do
          subject
          expect(cache.read(key)).to eq value
        end

        it 'should return original value' do
          expect(subject).to eq value
        end
      end

      context 'key is in cache' do
        before { cache.write(key, value) }

        it 'should return original value' do
          expect(subject).to eq value
        end
      end
    end
  end
end
