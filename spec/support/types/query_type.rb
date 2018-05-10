module Types
  class Query < ::GraphQL::Schema::Object
    field :integer, Int,     null: false
    field :string,  String,  null: false
    field :boolean, Boolean, null: false
    field :list,    [Int],   null: false
  end
end
