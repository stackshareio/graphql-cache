require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Builder do
      let(:raw) { nil }
      let(:method) { nil }

      subject { described_class.new(raw, method) }

      describe 'self#namify' do
        subject { described_class.namify(str) }

        context 'when string is a module name' do
          let(:str) { 'GraphQL::Relay::RelationConnection' }

          it { should eq 'relationconnection' }
        end

        context 'when string has capitols' do
          let(:str) { 'UPCASE' }

          it { should eq 'upcase' }
        end
      end

      describe '#deconstruct' do
        context 'when raw value is an array' do
          let(:raw) do
            [1, 2]
          end

          it 'should return the raw array' do
            expect(subject.deconstruct).to eq [1, 2]
          end

          context 'of custom types' do
            let(:raw) do
              [
                TestType.authorized_new(1, config[:query_context]),
                TestType.authorized_new(2, config[:query_context])
              ]
            end

            it 'should return array of inner objects' do
              expect(subject.deconstruct).to eq [1, 2]
            end
          end

        end

        context 'when raw value is a GraphQL relation' do
          let(:raw) do
            GraphQL::Relay::RelationConnection.new(
              [1, 2],
              config[:query_context]
            )
          end

          it 'should return inner "nodes"' do
            expect(subject.deconstruct).to eq [1, 2]
          end
        end

        context 'when raw value is an arbitrary object' do
          let(:obj) { 'foo' }
          let(:raw) { obj }

          it 'should return the object' do
            expect(subject.deconstruct).to eq obj
          end

          context 'that responds to "object"' do
            let(:raw) { TestType.authorized_new(2, config[:query_context]) }

            it 'should return inner object' do
              expect(subject.deconstruct).to eq 2
            end
          end
        end
      end

      describe '#build' do
        subject { described_class.new(raw, method) }

        context 'when method is "array"' do
          let(:method) { 'array' }
          let(:raw) do
            [1, 2]
          end

          context 'when field is a scalar' do
            config(field_definition: TestSchema.types['Test'].fields['ints'])

            it 'should return an array of scalars' do
              expect(subject.build config).to eq [1, 2]
            end
          end

          context 'when field is an object' do
            config(field_definition: TestSchema.types['Test'].fields['subObjects'])

            it 'should return an array of object types' do
              subject.build(config).each do |item|
                expect(item.class).to eq SubObjectType
              end
            end
          end
        end

        context 'when method is "collectionproxy"' do
          let(:query_context) { Hash.new }
          let(:method) { 'collectionproxy' }
          let(:raw) do
            [1, 2]
          end

          before do
            allow(query_context).to receive(:field)
            allow(query_context).to receive(:schema).and_return(TestSchema)
            config[:query_context] = query_context
            config[:parent_object] = TestType.authorized_new({},query_context)
            allow(GraphQL::Relay::BaseConnection).to receive(:connection_for_nodes).and_return(GraphQL::Relay::RelationConnection)
          end

          it 'should build a relation collection' do
            expect(subject.build config).to be_a GraphQL::Relay::RelationConnection
          end

          it 'should build a collection with raw value nodes' do
            expect(subject.build(config).nodes).to eq [1, 2]
          end
        end
      end
    end
  end
end
