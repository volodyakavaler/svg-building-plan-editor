class Floor < ActiveRecord::Base
  attr_accessor :editor_data

  belongs_to :building
  has_many :polygons, as: :imageable, dependent: :destroy
  has_many :rooms, dependent: :destroy

  validates :name, presence: true, length: { maximum: 1}
end
