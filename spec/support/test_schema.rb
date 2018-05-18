class SubObjectType < GraphQL::Schema::Object
  field_class GraphQL::Cache::Field

  field :an_id,     ID,      null: false
  field :a_string,  String,  null: false
  field :a_boolean, Boolean, null: false
  field :an_int,    Int,     null: false, cache: true
  field :a_float,   Float,   null: false

  def an_id;    123;   end
  def a_string; 'foo'; end
  def a_boolean; true; end
  def an_int;    73;   end
  def a_float;   3.14; end
end

class TestType < GraphQL::Schema::Object
  field_class GraphQL::Cache::Field

  field :expiry_int, Int, null: false, cache: { expiry: 10800 }

  field :an_id,       ID,              null: false
  field :a_string,    String,          null: false
  field :a_boolean,   Boolean,         null: false
  field :an_int,      Int,             null: false
  field :a_float,     Float,           null: false
  field :sub_object,  SubObjectType,   null: false

  field :ints,        [Int],           null: false, cache: true
  field :sub_objects, [SubObjectType], null: false

  def an_id;       123;   end
  def a_string;    'foo'; end
  def a_boolean;   true; end
  def an_int;      73;   end
  def a_float;     3.14; end
  def ints;        [1, 2]; end
  def sub_objects; [1, 2]; end
  def expiry_int;  12345; end
  def sub_object;  {}; end
end

class TestSchema < GraphQL::Schema
  query TestType

  middleware GraphQL::Cache::Middleware
end
