class CampusesController < ApplicationController
  before_action :set_campus, only: [:show, :edit, :update, :destroy]

  # GET /campuses
  # GET /campuses.json
  def index
    @campuses = Campus.all
  end

  # GET /campuses/1
  # GET /campuses/1.json
  def show
    @buildings = Building.all.where(campus: @campus.id)

    # преобразование массива точек в строку для SVG.js:
    @showPoints = []
    polygons_ids = Polygon.all.where(imageable_id: @campus.id).map{ |i| i.id }
    polygons_ids.each do |i|
      @showPoints << Point.all.where(polygon_id: i)
                              .sort_by{ |j| j[:priority] }
                              .map{ |j| "#{j.ox}, #{j.oy}" }
                              .join(" ")
    end
    # @buildings = Building.all.where(campus: @campus.id)
  end

  # GET /campuses/new
  def new
    @campus = Campus.new
  end

  # GET /campuses/1/edit
  def edit
  end

  # POST /campuses
  # POST /campuses.json
  def create
    @campus = Campus.new(campus_params)

    respond_to do |format|
      if @campus.save
        # создание ассоциативных полигонов и точек с данным кампусом:
        # editorData = params['editorData']
        # editorData = editorData.map{ |i| i.split(' ').map{ |j| j.split(',') } }
        # editorData.each do |obj|
        #   # type: editorData[i][-1].delete_at(-1).to_i
        #
        #   if (obj[-1][-1].to_i == 1)
        #     polygon = Polygon.new(imageable: @campus)
        #     polygon.save
        #     for i in 0 ... obj.size
        #       point = Point.create(ox: obj[i][0].to_f,
        #                            oy: obj[i][1].to_f,
        #                            priority: i,
        #                            polygon: polygon
        #                           )
        #       point.save
        #     end
        #   elsif(obj[-1][-1].to_i == 2)
        #     building = Building.new(name: "dfef",
        #                              address: "fgfggeg",
        #                              description: "wwfwfwf",
        #                              campus_id: @campus.id)
        #     building.save
        #     polygon = Polygon.new(imageable: building)
        #     polygon.save
        #     for i in 0 ... obj.size
        #       point = Point.create(ox: obj[i][0].to_f,
        #                            oy: obj[i][1].to_f,
        #                            priority: i,
        #                            polygon: polygon
        #                           )
        #       point.save
        #     end
        #   end

          # создание ассоциативного с этим кампусом полигона:
          # polygon = Polygon.new(imageable: @campus)
          # polygon.save
          # for i in 0 ... obj.size
          #   point = Point.create(ox: obj[i][0].to_f,
          #                        oy: obj[i][1].to_f,
          #                        priority: i,
          #                        polygon: polygon
          #                       )
          #   point.save
          # end
        # end

        format.html { redirect_to campuses_path, notice: t('flash.campus.create') }
        format.json { render :show, status: :created, location: @campus }
      else
        format.html { render :new }
        format.json { render json: @campus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campuses/1
  # PATCH/PUT /campuses/1.json
  def update
    respond_to do |format|
      if @campus.update(campus_params)
        format.html { redirect_to campuses_path, notice: t('flash.campus.update') }
        format.json { render :show, status: :ok, location: @campus }
      else
        format.html { render :edit }
        format.json { render json: @campus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campuses/1
  # DELETE /campuses/1.json
  def destroy
    @campus.destroy
    respond_to do |format|
      format.html { redirect_to campuses_url, notice: t('flash.campus.delete') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campus
      @campus = Campus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campus_params
      params.require(:campus).permit(:name, :description)
    end
end
