require 'spec_helper'

RSpec.describe GraphQL::Cache do
  it "has a version number" do
    expect(GraphQL::Cache::VERSION).not_to be nil
  end

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
      let(:key)    { 'key' }
      let(:config) { Hash.new }

      subject do
        described_class.fetch(key, config: config) { 'foo' }
      end

      context 'config->cache is not set' do
        it 'should call the block and return' do
          expect(described_class).to_not receive(:marshal_to_cache)
          expect(described_class).to_not receive(:marshal_from_cache)
          expect(subject).to eq 'foo'
        end
      end

      describe '#marshal_to_cache' do
        let(:key)    { 'key' }
        let(:config) { Hash.new }
        let(:obj)    { 'foo' }

        subject do
          described_class.marshal_to_cache(key, config) { obj }
        end

        context 'when object is a scalar' do
          it 'should write the result to cache' do
            expect(GraphQL::Cache.cache).to receive(:write).with(key, obj, expires_in: GraphQL::Cache.expiry)
            subject
          end

          it 'should return raw value' do
            allow(GraphQL::Cache.cache).to receive(:write)
            expect(subject).to eq obj
          end
        end

        context 'when object is a schema object' do
          let(:obj) do
            ::GraphQL::Schema::Object.new(
              'foo',
              nil
            )
          end

          it 'should write the marshaled value to cache' do
            expect(GraphQL::Cache.cache).to receive(:write).with(key, 'foo', expires_in: GraphQL::Cache.expiry)
            subject
          end

          it 'should return raw value' do
            allow(GraphQL::Cache.cache).to receive(:write)
            expect(subject).to eq obj
          end
        end

        context 'when object is an array' do
          let(:obj) do
            [
              ::GraphQL::Schema::Object.new(
                'foo',
                nil
              ),
              ::GraphQL::Schema::Object.new(
                'bar',
                nil
              )
            ]
          end

          it 'should write the marshaled value to cache' do
            expect(GraphQL::Cache.cache).to receive(:write).with(key, ['foo', 'bar'], expires_in: GraphQL::Cache.expiry)
            subject
          end

          it 'should return raw value' do
            allow(GraphQL::Cache.cache).to receive(:write)
            expect(subject).to eq obj
          end
        end

        context 'when object is Connection' do
          let(:nodes) { ['foo', 'bar'] }
          let(:obj) do
            GraphQL::Relay::RelationConnection.new(
              nodes,
              nil
            )
          end

          it 'should write the marshaled value to cache' do
            expect(GraphQL::Cache.cache).to receive(:write).with(key, ['foo', 'bar'], expires_in: GraphQL::Cache.expiry)
            subject
          end

          it 'should return raw value' do
            allow(GraphQL::Cache.cache).to receive(:write)
            expect(subject).to eq obj
          end
        end
      end
    end
  end
end
