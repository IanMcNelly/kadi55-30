require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post :create, { room_id: @user.room_id, access_token: @user.access_token, expires_at: @user.expires_at, oauth_id: @user.oauth_id, secret: @user.secret, capabilitiesUrl: "https://api.hipchat.com/v2/capabilities" }.to_json
  #   end

  #   assert_redirected_to user_path(assigns(:user))
  # end


  # test "should destroy user" do
  #   assert_difference('User.count', -1) do
  #     delete :destroy, id: @user
  #   end

  #   assert_redirected_to users_path
  # end
end
