require 'spec_helper'

module GraphQL
  module Cache
    RSpec.describe Key do
      let(:obj)        { double('Inner Object', id: 123, foo: 'bar') }
      let(:parent_obj) { double('Parent Object', object: obj ) }
      let(:type)       { CacheSchema.types['Customer'] }
      let(:field)      { type.fields['orders'] }
      let(:args) do
        {
          foo: 'bar'
        }
      end

      subject { described_class.new(parent_obj, args, type, field) }

      describe '#to_s' do
        it 'should return a string' do
          expect(subject.to_s).to be_a String
        end

        it 'should include the global key namespace string' do
          target = GraphQL::Cache.namespace
          expect(subject.to_s[0, target.length]).to eq GraphQL::Cache.namespace
        end
      end

      describe '#object_clause' do
        it 'should return a string with class name and identifier' do
          expect(subject.object_clause).to eq "RSpec::Mocks::Double:#{obj.id}"
        end

        context 'parent\' inner object is nil' do
          let(:obj) { nil }

          it 'should return nil' do
            expect(subject.object_clause).to eq nil
          end
        end
      end

      describe '#type_clause' do
        it 'should return the type name' do
          expect(subject.type_clause).to eq type.name
        end
      end

      describe '#field_clause' do
        it 'should return the field name' do
          expect(subject.field_clause).to eq field.name
        end
      end

      describe '#arguments_clause' do
        it 'returns the arguments hash as a 1-dimension array' do
          expect(subject.arguments_clause).to eq args.to_a.flatten
        end
      end

      describe '#object_identifier' do
        context 'when metadata key is a symbol' do
          before do
            field.metadata[:cache] = { key: :foo }
          end

          it 'calls the symbol on object' do
            expect(obj).to receive(:foo)
            subject.object_identifier
          end
        end

        context 'when metadata key is a proc' do
          let(:key_proc) do
            -> (obj) { 'baz' }
          end

          before do
            field.metadata[:cache] = { key: key_proc }
          end

          it 'calls the proc passing object' do
            expect(key_proc).to receive(:call).and_call_original
            subject.object_identifier
          end
        end

        context 'when metadata key is nil' do
          before do
            field.metadata[:cache] = { key: nil }
          end

          it 'uses guess_id' do
            expect(subject).to receive(:guess_id).and_call_original
            subject.object_identifier
          end
        end

        context 'when metadata key is an object' do
          before do
            field.metadata[:cache] = { key: 'foo' }
          end

          it 'returns metadata key' do
            expect(subject.object_identifier).to eq 'foo'
          end
        end
      end

      describe '#guess_id' do
        let(:obj) { 'foo' }

        it 'returns the object\'s object_id' do
          expect(subject.guess_id).to eq obj.object_id
        end

        context 'object responds to cache_key' do
          let(:obj) { double('Object', cache_key: 'foo') }

          it 'returns object.cache_key' do
            expect(obj).to receive(:cache_key)
            subject.guess_id
          end
        end

        context 'object responds to id' do
          let(:obj) { double('Object', id: 'foo') }

          it 'returns object.id' do
            expect(obj).to receive(:id)
            subject.guess_id
          end
        end

        context 'object responds to both cache_key and id' do
          let(:obj) { double('Object', id: 'foo', cache_key: 'bar') }

          it 'uses cache_key' do
            expect(obj).to receive(:cache_key)
            expect(obj).to_not receive(:id)
            subject.guess_id
          end
        end
      end
    end
  end
end
