class MachineTranslation < ActiveRecord::Base
  attr_accessible :article_id, :lang, :paragraph_idx, :text, :text_idx, :translation, :translator, :vote
  belongs_to :article
end
