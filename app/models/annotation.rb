# TODO: remove columns
class Annotation < ActiveRecord::Base
  attr_accessible :lang, :paragraph_idx, :selected_text, :text_idx, :translation, :article_id, :article, :vote
  belongs_to :article
  has_many :annotation_histories
end
