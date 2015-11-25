class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :oauth_id
      t.string :secret
      t.string :access_token
      t.integer :expires_in

      t.timestamps null: false
    end
  end
end
