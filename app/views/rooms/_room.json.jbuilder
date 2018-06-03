json.extract! room, :id, :name, :description, :floor_id, :created_at, :updated_at
json.url room_url(room, format: :json)
