class CreateFloors < ActiveRecord::Migration
  def change
    create_table :floors do |t|
      t.string :name
      t.string :description
      t.references :building, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
