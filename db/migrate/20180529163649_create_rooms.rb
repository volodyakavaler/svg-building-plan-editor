class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :description
      t.references :floor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
