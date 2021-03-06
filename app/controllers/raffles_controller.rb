class RafflesController < ApplicationController
  before_action :set_raffle, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:new, :edit, :create, :update, :destroy]
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  layout 'admin', except: [:show, :raffle_select]

  def raffle_select
    set_raffle
    @raffle.random_select if @raffle.winner_ticket.nil?

    respond_to do |format|
      format.html
      format.json { render json: @raffle.winner_ticket }
    end
  end

  # GET /raffles
  # GET /raffles.json
  def index
    @raffles = Raffle.presentation_admin.all
  end

  # GET /raffles/1
  # GET /raffles/1.json
  def show
  end

  # GET /raffles/new
  def new
    @raffle = Raffle.new
  end

  # GET /raffles/1/edit
  def edit
  end

  # POST /raffles
  # POST /raffles.json
  def create
    @raffle = Raffle.new(raffle_params)

    respond_to do |format|
      if @raffle.save
        format.html { redirect_to @raffle, notice: 'Rifa cadastrada com sucesso.' }
        format.json { render :show, status: :created, location: @raffle }
      else
        format.html { render :new }
        format.json { render json: @raffle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raffles/1
  # PATCH/PUT /raffles/1.json
  def update
    respond_to do |format|
      if @raffle.update(raffle_params)
        # redirect to request.referrer
        format.html { redirect_to request.referrer, notice: 'Rifa atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @raffle }
      else
        format.html { render :edit }
        format.json { render json: @raffle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raffles/1
  # DELETE /raffles/1.json
  def destroy
    @raffle.destroy
    respond_to do |format|
      format.html { redirect_to raffles_url, notice: 'Rifa excluída com sucesso.' }
      format.json { head :no_content }
    end
  end

  def payback
    @raffle = Raffle.presentation_admin.find(params[:raffle_id])
    @raffle.payback
    redirect_to raffles_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_raffle
      @raffle = Raffle.presentation_admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def raffle_params
      params.require(:raffle).permit(
      :title,
      :description,
      :points,
      :amount,
      :active,
      :image,
      :avatar,
      :category_id,
      :deadline)
    end
end
