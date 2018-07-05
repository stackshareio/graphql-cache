require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Fetcher do
      describe 'graphql-ruby instrumentation API' do
        it { should respond_to :instrument }
      end

      describe '#instrument' do
        let(:type)  { CacheSchema.types['Customer'] }
        let(:field) do
          double(
            'graphql-ruby field',
            resolve_proc: ->(obj, args, ctx) { nil },
            redefine: nil
          )
        end

        it 'should redefine the resolution proc' do
          expect(field).to receive(:redefine)
          subject.instrument(type, field)
        end
      end
    end
  end
end
