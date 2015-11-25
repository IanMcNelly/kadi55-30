class FixColumnName < ActiveRecord::Migration
  def change
  	rename_column :users, :expires_in, :expires_at
  end
end
