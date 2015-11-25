class AddRoomIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :room_id, :string
  end
end
