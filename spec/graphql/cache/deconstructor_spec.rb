require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Deconstructor do
      describe '#perform' do
        let(:raw) { 'foo' }
        let(:method) { 'object' }

        subject { described_class.new(raw, method) }

        it 'should returns the raw object' do
          expect(subject.perform).to eq raw
        end

        context 'when object responds to object' do
          let(:raw) { double('Raw', object: 'foo') }

          it 'should return raw.object' do
            expect(subject.perform).to eq raw.object
          end
        end

        context 'when method is "array"' do
          let(:raw)    { [1,2,3] }
          let(:method) { 'array' }

          it 'should return a flat array' do
            expect(subject.perform).to eq raw
          end

          context 'objects in array are GraphQL::Schema::Objects' do
            let(:raw) do
              [
                CustomerType.authorized_new('foo', query.context),
                CustomerType.authorized_new('bar', query.context),
              ]
            end

            it 'should return an array of the inner objects' do
              expect(subject.perform).to eq ['foo', 'bar']
            end
          end
        end

        context 'when method is "collectionproxy"' do
          let(:raw)    { [1,2,3] }
          let(:method) { 'collectionproxy' }

          it 'should return a flat array' do
            expect(subject.perform).to eq raw
          end

          context 'objects in array are GraphQL::Schema::Objects' do
            let(:raw) do
              [
                CustomerType.authorized_new('foo', query.context),
                CustomerType.authorized_new('bar', query.context),
              ]
            end

            it 'should return an array of the inner objects' do
              expect(subject.perform).to eq ['foo', 'bar']
            end
          end
        end

        context 'when raw is a subclass of GraphQL::Relay::BaseConnection' do
          let(:nodes) { [1,2,3] }
          let(:raw) { GraphQL::Relay::BaseConnection.new(nodes, []) }

          it 'should return a flat array of nodes' do
            expect(subject.perform).to eq [1,2,3]
          end
        end
      end
    end
  end
end
