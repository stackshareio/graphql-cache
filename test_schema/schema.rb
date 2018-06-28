require 'sequel'

DB = Sequel.sqlite

DB.create_table :customers do
  primary_key :id
  String :display_name
  String :email
end
