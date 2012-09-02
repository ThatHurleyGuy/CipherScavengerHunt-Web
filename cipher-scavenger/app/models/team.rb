class Team < ActiveRecord::Base
	validates :netid, :uniqueness => true
	validates :name, :uniqueness => true
  	attr_accessible :netid, :name, :pin, :score, :message
  	has_one :message
end
