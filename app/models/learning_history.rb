class LearningHistory < ActiveRecord::Base
  attr_accessible :translation_pair_id, :test_count, :user_id, :view_count, :lang
  validates_uniqueness_of :user_id, :scope => :translation_pair_id
  belongs_to :users
end
