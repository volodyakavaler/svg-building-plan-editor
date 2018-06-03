class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.float :ox
      t.float :oy
      t.integer :priority
      t.references :polygon, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
