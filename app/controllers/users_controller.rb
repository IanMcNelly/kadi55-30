require 'net/http'
require 'uri'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # TODO: Figure out better way to do this
  skip_before_filter :verify_authenticity_token

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  # def show
  # end

  # GET /users/new
  # def new
  #  @user = User.new
  # end

  # GET /users/1/edit
  # def edit
  # end

  # POST /users
  # POST /users.json
  def create
    result = Net::HTTP.get(URI.parse(user_params[:capabilitiesUrl].to_s.gsub('https:', 'http:')))
    unless result.include?('HipChat')
      format.json { render status: :unprocessable_entity }
    end

    @user = User.new(oauth_id: user_params[:oauthId],
                     room_id: user_params[:roomId],
                     secret: user_params[:oauthSecret])

    if @user.save
      render nothing: true, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
  #  respond_to do |format|
  #    if @user.update(user_params)
  #      format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #      format.json { render :show, status: :ok, location: @user }
  #    else
  #      format.html { render :edit }
  #      format.json { render json: @user.errors, status: :unprocessable_entity }
  #    end
  #  end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    redirect_to('https://hipchat.com/addons/')
    # render :nothing => true, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by(oauth_id: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    # Parameters: {"oauthId"=>"xxxxxx-xxxxx-xxxx-xxxx-xxxxxxxxx",
    #             "capabilitiesUrl"=>"https://api.hipchat.com/v2/capabilities",
    #             "roomId"=>1234567,
    #             "groupId"=>1234,
    #             "oauthSecret"=>"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    #             "user"=>{}
    # }
    params.permit(:oauthId, :capabilitiesUrl, :roomId, :groupId, :oauthSecret, :user, :instance, :coupa_api_key)
  end
end
