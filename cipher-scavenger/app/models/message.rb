class Message < ActiveRecord::Base
  attr_accessible :decoded, :encoded, :parity, :level, :team
  belongs_to :team

	def get_qr_code_url
		dict = {:id =>  self.id, :encoded =>  self.encoded, :level =>  self.level}
		if( self.level == 3) 
	    	dict[:parity] = self.parity
		end
		j = ActiveSupport::JSON
		test = j.encode(dict)

		return "https://chart.googleapis.com/chart?cht=qr&chs=400x400&chl=" + test
	end
end
