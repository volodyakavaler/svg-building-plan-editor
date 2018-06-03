class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :address
      t.string :description
      t.references :campus, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
