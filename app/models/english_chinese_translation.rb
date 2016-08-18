class EnglishChineseTranslation < ActiveRecord::Base
  attr_accessible :chinese_vocabulary_id, :chinese_vocabulary_id, :pos_tag
  
  validates_uniqueness_of :chinese_vocabulary_id, :scope => :chinese_vocabulary_id
  #has_many :meanings_example_sentences, :dependent => :destroy
  #has_many :histories, :dependent => :destroy
  belongs_to :chinese_vocabularies
  belongs_to :english_vocabularies
end
