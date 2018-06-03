class CreateCampuses < ActiveRecord::Migration
  def change
    create_table :campuses do |t|
      t.string :name, null: false, limit: 32
      t.string :description, limit: 64

      t.index [:name], unique: true

      t.timestamps null: false
    end
  end
end
