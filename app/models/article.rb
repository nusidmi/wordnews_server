class Article < ActiveRecord::Base
  attr_accessible :annotation_count, :lang, :url, :url_postfix, :website
  has_many :annotation
end
