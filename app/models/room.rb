class Room < ActiveRecord::Base
  belongs_to :floor
  belongs_to :roomtype
  has_many :polygons, as: :imageable, dependent: :destroy

  # поиск
  def self.search(params)
    # result = Order.includes(:tariff, {:automobile => :drivers}).references(:tariff, {:automobile => :drivers})
    result = Room.all

    if params['room_name'].present?
      result = result.where(name: params['room_name'])
    end
    if params['room_roomtype'].present?
      result = result.where(roomtype_id: params['room_roomtype'])
    end
    if params['room_capacity_from'].present?
      result = result.where.not(capacity: 0...params['room_capacity_from'].to_i)
    end
    if params['room_capacity_to'].present?
      result = result.where(capacity: 0..params['room_capacity_to'].to_i)
    end

    result.all
  end
end
