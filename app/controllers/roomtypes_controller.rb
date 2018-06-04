class RoomtypesController < ApplicationController
  before_action :set_roomtype, only: [:edit, :update, :destroy]

  # GET /roomtypes
  # GET /roomtypes.json
  def index
    @roomtypes = Roomtype.all
  end

  # GET /roomtypes/new
  def new
    @roomtype = Roomtype.new
  end

  # GET /roomtypes/1/edit
  def edit
  end

  # POST /roomtypes
  # POST /roomtypes.json
  def create
    @roomtype = Roomtype.new(roomtype_params)

    respond_to do |format|
      if @roomtype.save
        format.html { redirect_to roomtypes_url, notice: t('flash.roomtype.create') }
        format.json { render :show, status: :created, location: @roomtype }
      else
        format.html { render :new }
        format.json { render json: @roomtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roomtypes/1
  # PATCH/PUT /roomtypes/1.json
  def update
    respond_to do |format|
      if @roomtype.update(roomtype_params)
        format.html { redirect_to roomtypes_url, notice: t('flash.roomtype.update') }
        format.json { render :show, status: :ok, location: @roomtype }
      else
        format.html { render :edit }
        format.json { render json: @roomtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roomtypes/1
  # DELETE /roomtypes/1.json
  def destroy
    @roomtype.destroy

    unless @roomtype.errors.messages.blank?
      respond_to do |format|
        format.html { redirect_to roomtypes_url, notice: t('flash.roomtype.deleteno') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to roomtypes_url, notice: t('flash.roomtype.delete') }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_roomtype
      @roomtype = Roomtype.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def roomtype_params
      params.require(:roomtype).permit(:name, :description)
    end
end
