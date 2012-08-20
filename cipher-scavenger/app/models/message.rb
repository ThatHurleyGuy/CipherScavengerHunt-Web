class Message < ActiveRecord::Base
  attr_accessible :decoded, :encoded, :level
end
