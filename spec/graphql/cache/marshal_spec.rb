require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Marshal do
      let(:key) { 'key' }
      let(:doc) { 'value' }

      subject { Marshal.new(key) }

      describe 'Class methods' do
        describe '#[]' do
          it 'should initialize a new Marshal object' do
            marshal = Marshal[key]
            expect(marshal).to be_a Marshal
            expect(marshal.key).to eq key
          end
        end
      end

      describe 'helpers' do
        it 'should forward :cache to module' do
          expect(GraphQL::Cache).to receive(:cache)
          subject.cache
        end

        it 'should forward :logger to module' do
          expect(GraphQL::Cache).to receive(:logger)
          subject.logger
        end
      end

      describe '#read' do
        let(:config) { true }

        context 'when cache object exists' do
          before do
            cache.write(key, doc)
          end

          it 'should return cached value' do
            expect(subject.read).to eq doc
          end
        end

        context 'when cache object does not exist' do
          before { cache.clear }

          it 'should return nil' do
            expect(subject.read).to be_nil
          end
        end
      end

      describe '#write' do
        let(:config) { true }

        it 'should return the resolved value' do
          expect(subject.write(config) { doc }).to eq doc
        end

        it 'should write the object to cache' do
          expect(cache).to receive(:write).with(key, doc, expires_in: GraphQL::Cache.expiry)
          subject.write(config) { doc }
        end

        context 'when the resolved value is a promise', skip: !defined?(Promise) do
          let(:doc) { Promise.resolve('value') }

          it 'should write the promise resolution value to the cache' do
            expect(cache).to receive(:write).with(key, doc.value, expires_in: GraphQL::Cache.expiry)
            subject.write(config) { doc }
          end

          it 'should return a promise that resolves to the value' do
            expect((subject.write(config) { doc }).value).to eq('value')
          end
        end
      end

      describe '#expiry' do
        context 'when cache config is a boolean' do
          let(:config) { true }

          it 'should return global expiry' do
            expect(subject.expiry(config)).to eq GraphQL::Cache.expiry
          end
        end

        context 'when cache config is a hash' do
          let(:expiry) { '999' }
          let(:config) do
            {
              expiry: expiry
            }
          end

          it 'should return the config expiry' do
            expect(subject.expiry(config)).to eq expiry
          end
        end
      end
    end
  end
end
