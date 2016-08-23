class VoteHistory < ActiveRecord::Base
  attr_accessible :pair_id, :source, :user_id, :vote
  belongs_to :user
end
