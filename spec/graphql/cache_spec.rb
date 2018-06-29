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

    it { should respond_to :configure }

    describe '#configure' do
      it 'should yield self to allow setting config' do
        expect{
          described_class.configure { |c| c.force = true }
        }.to change{
          described_class.force
        }.to true
      end
    end
  end
end
