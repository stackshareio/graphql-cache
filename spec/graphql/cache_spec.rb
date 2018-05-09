require 'spec_helper'

RSpec.describe GraphQL::Cache do
  it "has a version number" do
    expect(GraphQL::Cache::VERSION).not_to be nil
  end

  context 'configuration' do
    describe '@@global_expiry' do
    end
    describe '@@force' do
    end
    describe '@@namespace' do
    end
    describe '@@cache' do
    end
    describe '@@logger' do
    end
  end
end
