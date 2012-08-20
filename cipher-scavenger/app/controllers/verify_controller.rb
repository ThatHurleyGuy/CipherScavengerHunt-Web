class VerifyController < ApplicationController
	
	def show
		id = params[:id]
		userDecoded = params[:decoded]
		message = Message.find(id)
		decoded = message.decoded
		correct = decoded == userDecoded
		render :json => {:result => correct}.to_json
	end

end
