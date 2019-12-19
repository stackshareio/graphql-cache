require 'spec_helper'

RSpec.describe 'caching connection fields' do
  class StubLogger < Logger
    def initialize
      @strio = StringIO.new
      super(@strio)
    end

    def messages
      @strio.string
    end
  end

  let(:query) do
    %Q{
      {
        customer(id: #{customer.id}) {
          orders {
            edges {
              node {
                id
              }
            }
          }
        }
      }
    }
  end

  let(:sql_logger) do
    StubLogger.new.tap do |logger|
      logger.formatter = proc do |_severity, _datetime, _progname, msg|
        raw_sql = msg.match(/.*(?<sql>SELECT .*)/)["sql"]

        "#{raw_sql}\n"
      end
    end
  end

  shared_examples "be a correct cold and warm" do
    let(:reference) do
      {"data" => {"customer" => {"orders" => {"edges" => [{"node" => {"id" =>1 }}, {"node" => {"id" => 2}}, {"node" => {"id" => 3}}]}}}}
    end

    it 'produces the same result on miss or hit' do
      cold_results = execute(query)
      warm_results = execute(query)

      expect(cold_results).to eq(reference)
      expect(cold_results).to eq warm_results
    end
  end

  describe 'Seqeul' do
    def execute(query, context = {})
      CacheSchema.execute(query, context: context)
    end
    let(:customer) { Customer.last }

    before { DB.logger = sql_logger }

    it_behaves_like "be a correct cold and warm"

    it 'calls sql engine only one time per cached field' do
      5.times { execute(query) }

      expect(sql_logger.messages).to eq(
        <<~SQL
          SELECT * FROM `customers` ORDER BY `id` DESC LIMIT 1
          SELECT * FROM `customers` WHERE `id` = '1'
          SELECT * FROM `orders` WHERE (`orders`.`customer_id` = 1)
        SQL
      )
    end
  end

  describe 'ActiveRecord' do
    def execute(query, context = {})
      AR::CacheSchema.execute(query, context: context)
    end

    let(:customer) { AR::Customer.last }

    before { ActiveRecord::Base.logger = sql_logger }

    it_behaves_like "be a correct cold and warm"

    it 'calls sql engine only one time per cached field' do
      5.times { execute(query) }

      expect(sql_logger.messages).to eq(
        <<~SQL
          SELECT "customers".* FROM "customers" ORDER BY "customers"."id" DESC LIMIT ?  [["LIMIT", 1]]
          SELECT "customers".* FROM "customers" WHERE "customers"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
          SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = ?  [["customer_id", 1]]
        SQL
      )
    end
  end
end
