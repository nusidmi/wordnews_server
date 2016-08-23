module Utilities::ArticleUtil
  def self.get_or_create_article(url, url_postfix, lang, website, title, publication_date)
    article = Article.where('url_postfix=? AND lang=?', url_postfix, lang).first

    if article.nil?
      article = Article.new(website: website, url: url, url_postfix: url_postfix, 
                            lang: lang, annotation_count: 0, title: title, 
                            publication_date: publication_date)
      article.save
    end
    return article
  end
  
  
  def self.get_article(url_postfix, lang)
    article = Article.where('url_postfix=? AND lang=?', url_postfix, lang).first
    return article
  end
  
  def self.get_article_id(url_postfix, lang)
    article_id = Article.where('url_postfix=? AND lang=?', url_postfix, lang).pluck(:id).first
    return article_id
  end
  
  
  
  
end