class CreateRoomtypes < ActiveRecord::Migration
  def change
    create_table :roomtypes do |t|
      t.string :name, null: false, limit: 32
      t.string :description, limit: 64

      t.index [:name], unique: true

      t.timestamps null: false
    end
  end
end
