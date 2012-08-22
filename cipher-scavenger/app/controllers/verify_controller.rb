class VerifyController < ApplicationController
	
	def show
		message_id = params[:messageid]
		team_id = params[:teamid]
		user_decoded = params[:decoded]
		pin = params[:pin]
		message = Message.find(message_id)
		host_team = message.team
		crack_team = Team.find(team_id)
		decoded = message.decoded
		correct = decoded == user_decoded

		if correct
			host_team.score += 1
			crack_team.score += message.level
			host_team.save
			crack_team.save
		end

		render :json => {:result => correct}.to_json
	end

end
