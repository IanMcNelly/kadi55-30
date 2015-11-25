class WebhookController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token

  def parse
  	puts "IN webhook parse!"
  	render :nothing => true, status: :ok
  end

end