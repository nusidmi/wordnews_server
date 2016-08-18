class EnglishChineseTranslation < ActiveRecord::Base
  attr_accessible :chinese_vocabularies_id, :chinese_vocabularies_id, :pos_tag
  
  validates_uniqueness_of :chinese_vocabularies_id, :scope => :chinese_vocabularies_id
  #has_many :meanings_example_sentences, :dependent => :destroy
  #has_many :histories, :dependent => :destroy
  belongs_to :chinese_vocabularies
  belongs_to :english_vocabularies
end
