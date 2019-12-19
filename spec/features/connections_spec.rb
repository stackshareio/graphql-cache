require 'spec_helper'

def execute(query, context = {})
  CacheSchema.execute(query, context: context)
end

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
        customer(id: #{Customer.last.id}) {
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
        raw_sql = msg.match(/\(.*\)\s(?<sql>.*)/)["sql"]

        "#{raw_sql}\n"
      end
    end
  end

  before { DB.logger = sql_logger }

  it 'produces the same result on miss or hit' do
    cold_results = execute(query)
    warm_results = execute(query)

    expect(cold_results).to eq warm_results
  end

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
