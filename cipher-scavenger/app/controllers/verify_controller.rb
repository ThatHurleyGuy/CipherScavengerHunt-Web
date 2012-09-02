class VerifyController < ApplicationController
	
	def show
		message_id = params[:messageid]
		team_netid = params[:teamid]
		user_decoded = params[:decoded]
		pin = params[:pin]
		message = Message.find(message_id)
		host_team = message.team

		crack_team = Team.where("netid = :netid", {:netid => team_netid}).first
		decoded = message.decoded
		correct = decoded == user_decoded

		scan = Scan.where("team_id_scanner = ? AND team_id_scannee = ?", crack_team.id, host_team.id).first

		if not scan.nil?
			puts scan.scanner
			puts scan.scannee
			render :json => {:result => false, :reason => "Already Scanned"}.to_json
			return
		end

		if correct
			host_team.score += 1
			crack_team.score += message.level
			host_team.save
			crack_team.save
			Scan.create(:scanner => crack_team, :scannee => host_team);
			render :json => {:result => correct}.to_json
		else
			render :json => {:result => correct, :reason => "Incorrect Decoding"}.to_json
		end

	end

end
