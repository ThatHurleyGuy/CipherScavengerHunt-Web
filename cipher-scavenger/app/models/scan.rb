class Scan < ActiveRecord::Base
	attr_accessible :scanner, :scannee
	belongs_to :scanner, :class_name => 'Team', :foreign_key => 'team_id_scanner'
	belongs_to :scannee, :class_name => 'Team', :foreign_key => 'team_id_scannee'

end