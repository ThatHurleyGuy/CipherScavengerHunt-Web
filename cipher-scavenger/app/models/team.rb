class Team < ActiveRecord::Base
  attr_accessible :name, :pin, :score, :message
  has_one :message
end
