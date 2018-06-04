class Roomtype < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 32}, uniqueness: true
  validates :description, length: {maximum: 64}

  has_many :rooms, dependent: :restrict_with_error
end
