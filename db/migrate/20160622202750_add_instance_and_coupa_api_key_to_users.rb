class AddInstanceAndCoupaApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instance, :string
    add_column :users, :coupa_api_key, :string
  end
end
