class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  #def show
  #end

  # GET /users/new
  #def new
  #  @user = User.new
  #end

  # GET /users/1/edit
  #def edit
  #end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  #def update
  #  respond_to do |format|
  #    if @user.update(user_params)
  #      format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #      format.json { render :show, status: :ok, location: @user }
  #    else
  #      format.html { render :edit }
  #      format.json { render json: @user.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(:oauth_id => params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      #Parameters: {"oauthId"=>"10637af2-244f-4f3e-915c-f0021a2c7429", 
      #             "capabilitiesUrl"=>"https://api.hipchat.com/v2/capabilities", 
      #             "roomId"=>2199252, 
      #             "groupId"=>2002, 
      #             "oauthSecret"=>"w0fKHhwizukYzfYFRIiH4IPdaAFG3OIgVl2kXCnh", 
      #             "user"=>{}
      #}
      params.require(:oauthId, :capabilitiesUrl, :roomId, :groupId, :oauthSecret)
    end
end
