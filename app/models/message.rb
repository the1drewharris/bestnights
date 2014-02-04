class Message < ActiveRecord::Base
  attr_accessible :message, :sender_id, :sender_type, :to_id, :to_type, :type, :status
end
