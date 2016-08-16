class LearningHistory < ActiveRecord::Base
  attr_accessible :meaning_id, :test_count, :user_id, :view_count, :lang
  validates_uniqueness_of :user_id, :scope => :meaning_id
  belongs_to :users
  belongs_to :meanings
end
