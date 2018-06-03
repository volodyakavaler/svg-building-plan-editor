class Campus < ActiveRecord::Base
  has_many :buildings, dependent: :destroy
  has_many :polygons, as: :imageable, dependent: :destroy

  validates :name, presence: true, length: { maximum: 32}, uniqueness: true
  validates :description, length: {maximum: 64}
end
