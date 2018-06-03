class Building < ActiveRecord::Base
  belongs_to :campus
  has_many :floors, dependent: :destroy
  has_many :polygons, as: :imageable, dependent: :destroy
end
