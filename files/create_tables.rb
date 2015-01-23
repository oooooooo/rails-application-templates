class CreateTables < ActiveRecord::Migration
  def change
    eval File.read( Rails.root.join('db', 'schema.rb') ).match(/ActiveRecord::Schema\.define\(version: \d+?\) do(.+)end/m)[1]
  end
end
