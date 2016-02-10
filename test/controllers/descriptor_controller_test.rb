require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	test "should reply with json" do
		get :index
		assert_response :success
	end

end