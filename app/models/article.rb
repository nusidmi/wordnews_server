class Article < ActiveRecord::Base
  attr_accessible :annotation_count, :lang, :url, :url_postfix, :website, :title, :publication_date
end
