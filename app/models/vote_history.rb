class VoteHistory < ActiveRecord::Base
  attr_accessible :pair_id, :source, :user_id, :vote, :is_explicit
  belongs_to :user
end
