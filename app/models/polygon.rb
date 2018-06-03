class Polygon < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  has_many :points, dependent: :destroy
end
