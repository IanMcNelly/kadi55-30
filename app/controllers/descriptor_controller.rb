class DescriptorController < ApplicationController

  def index
  	#probably a better way to do this...
  	descriptor = Hash.new
  	descriptor[:name] = "Kadi 55-30"
  	descriptor[:description] = "Integration for Hipchat to connect Destiny news and info"
  	descriptor[:key] = "com.test.kadi55-30"
  	descriptor[:links][:homepage] = "https://mighty-meadow-7891.herokuapp.com/"
  	descriptor[:links][:self] = "https://mighty-meadow-7891.herokuapp.com/descriptor/"
  	descriptor[:capabilities][:hipchatApiConsumer][:fromName] = "Kadi 55-30"
  	descriptor[:capabilities][:hipchatApiConsumer][:scopes] = ["send_notification"]

  	render :json => descriptor.to_json
  end

end