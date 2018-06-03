class AddParamsToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :capacity, :integer
    add_column :rooms, :computers, :integer
    add_reference :rooms, :roomtype, index: true, foreign_key: true
  end
end
