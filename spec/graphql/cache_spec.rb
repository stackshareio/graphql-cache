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
    end
  end
end
