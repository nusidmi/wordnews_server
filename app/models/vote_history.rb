class VoteHistory < ActiveRecord::Base
  attr_accessible :annotation_id, :user_id, :vote
  belongs_to :annotation
  belongs_to :user
end
