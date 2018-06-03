class FloorsController < ApplicationController
  before_action :set_floor, only: [:show, :edit, :update, :destroy]

  # GET /floors
  # GET /floors.json
  def index
    @floors = Floor.all
  end

  # GET /floors/1
  # GET /floors/1.json
  def show
    @rooms = Room.all.where(floor_id: @floor.id)

    # преобразование массива точек в строку для SVG.js (для полигонов этажей):
    @showPointsOfFloor = []
    polygons_ids = Polygon.all.where(imageable_id: @floor.id).map{ |i| i.id }
    polygons_ids.each do |i|
      @showPointsOfFloor << Point.all.where(polygon_id: i)
                              .sort_by{ |j| j[:priority] }
                              .map{ |j| "#{j.ox}, #{j.oy}" }
                              .join(" ")
    end

    # преобразование массива точек в строку для SVG.js (для полигонов аудиторий):
    @showPointsOfRooms = []
    polygons_ids = Polygon.all.where(imageable_id: Room.all.where(floor_id: @floor.id)).map{ |i| i.id }
    polygons_ids.each do |i|
      @showPointsOfRooms << Point.all.where(polygon_id: i)
                              .sort_by{ |j| j[:priority] }
                              .map{ |j| "#{j.ox}, #{j.oy}" }
                              .join(" ")
    end
  end

  # GET /floors/new
  def new
    if params[:building]
      @floor = Floor.new(building_id: params[:building])
    else
      @floor = Floor.new
    end
  end

  # GET /floors/1/edit
  def edit
    # сбор информации о помещениях:
    @rooms_for_draw = []
    room_objects = Polygon.all.where(imageable: Room.all.where(floor_id: @floor.id))
    room_objects.each do |obj|
      room = Room.all.where(id: obj.imageable_id)[0]
      @rooms_for_draw << { points:      Point.all.where(polygon_id: obj)
                                                  .sort_by{ |j| j[:priority] }
                                                  .map{ |j| "#{j.ox}, #{j.oy}" }
                                                  .join(" "),
                           name:        room.name,
                           description: room.description,
                           capacity:    room.capacity,
                           computers:   room.computers,
                           roomtype:    room.roomtype_id,
                           id:          Polygon.all.where(imageable: room)[0].id
                         }
    end
  end

  # POST /floors
  # POST /floors.json
  def create
    @floor = Floor.new(floor_params)

    respond_to do |format|
      if @floor.save
        editorData = @floor.editor_data
        editorData = editorData.split("<END>").map{|i| i.split("<NEXT>")}
        editorData.each do |obj|
          if obj[0] == 'submain'
            object = Room.new(name: obj[1],
                            description: obj[2],
                            capacity: obj[3],
                            computers: obj[4],
                            roomtype_id: Roomtype.all.where(id: obj[5].to_i)[0],
                            floor_id: @floor.id)
            object.save
          elsif obj[0] == 'main'
            object = @floor
          end
          polygon = Polygon.new(imageable: object)
          polygon.save
          points = obj[6].split(" ").map{|i| i.split(",")}
          for i in 0 ... points.size
            point = Point.create(ox: points[i][0].to_f,
                                 oy: points[i][1].to_f,
                                 priority: i,
                                 polygon: polygon
                                )
            point.save
          end
        end

        format.html { redirect_to @floor, notice: t('flash.floor.create')  }
        format.json { render :show, status: :created, location: @floor }
      else
        format.html { render :new }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /floors/1
  # PATCH/PUT /floors/1.json
  def update
    @rooms_for_draw = []

    respond_to do |format|
      if @floor.update(floor_params)

        editorData = @floor.editor_data
        editorData = editorData.split("<END>").map{|i| i.split("<NEXT>")}
        editorData.each do |obj|
          if obj[7] == 'edit'
            # Обновление точек:

            Point.all.where(polygon_id: obj[6]).each{ |point| point.destroy }
            points = obj[8].gsub(", ", ",").split(" ").map{ |j| j.split(',') }
            for i in 0 ... points.size
              point = Point.create(ox: points[i][0].to_f,
                                   oy: points[i][1].to_f,
                                   priority: i,
                                   polygon_id: obj[6]
                                  )
              point.save
            end

            if obj[0] == 'submain'
              # Обновление аудиторий:
              room = Room.all.where(id: Polygon.all.where(id: obj[6].to_i)[0].imageable_id)[0]
              room.update(name: obj[1],
                          description: obj[2],
                          capacity: obj[3],
                          computers: obj[4],
                          roomtype_id: Roomtype.all.where(id: obj[5].to_i)[0]
                          )
            end
          elsif obj[7] == 'destroy'
            Point.all.where(polygon_id: obj[6]).each{ |point| point.destroy }
            if obj[0] == 'submain'
              # raise ("#{obj[6]}")
              room = Room.all.where(id: Polygon.all.where(id: obj[6].to_i)[0].imageable_id)[0]
              room.destroy
            end
          elsif obj[7] == 'new'
            if obj[0] == 'submain'
              object = Room.new(name: obj[1],
                              description: obj[2],
                              capacity: obj[3],
                              computers: obj[4],
                              roomtype_id: Roomtype.all.where(id: obj[5].to_i)[0],
                              floor_id: @floor.id)
              object.save
            elsif obj[0] == 'main'
              object = @floor
            end
            polygon = Polygon.new(imageable: object)
            polygon.save
            points = obj[8].gsub(", ", ",").split(" ").map{ |j| j.split(',') }
            for i in 0 ... points.size
              point = Point.create(ox: points[i][0].to_f,
                                   oy: points[i][1].to_f,
                                   priority: i,
                                   polygon: polygon
                                  )
              point.save
            end
          end
        end

        format.html { redirect_to @floor, notice: t('flash.floor.update')  }
        format.json { render :show, status: :ok, location: @floor }
      else
        format.html { render :edit }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /floors/1
  # DELETE /floors/1.json
  def destroy
    @floor.destroy
    respond_to do |format|
      format.html { redirect_to @floor.building, notice: t('flash.floor.delete')  }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_floor
      @floor = Floor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def floor_params
      params.require(:floor).permit(:name, :description, :building_id, :editor_data)
    end
end
