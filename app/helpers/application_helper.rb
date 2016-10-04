module ApplicationHelper
  def social_auth_path(provider, status, user_id=nil)
    if !user_id.nil?
      "/auth/#{provider.to_s}?status=" + status.to_s + "&user_id=" + user_id.to_s
    else
      "/auth/#{provider.to_s}?status=" + status.to_s
    end
  end

  def facebook_most_annotated_share_path(lang, num, from_date, to_date, user_id = nil )
    if user_id.nil?
      lang_num_str = ""

      lang_num_str = lang.nil? ? lang_num_str : lang_num_str+"lang="+lang.to_s
      lang_num_str = num.nil? ? lang_num_str : lang_num_str+"&num="+num.to_s

      lang_num_str = from_date.nil? ? lang_num_str : lang_num_str+"&from_date="+from_date.to_s
      lang_num_str = to_date.nil? ? lang_num_str : lang_num_str+"&to_date="+to_date.to_s

      return 'https://www.facebook.com/dialog/feed?'+
            'app_id=' + ENV['FACEBOOK_KEY'].to_s +
            '&display=popup&amp;caption=Most%20annotated%20articles' +
            '&link=' + url_encode(ENV['HOST_ADDRESS'] + '/show_most_annotated_urls?'+ lang_num_str) +
            '&redirect_uri=' + url_encode(ENV['HOST_ADDRESS'] + '/show_most_annotated_urls?'+ lang_num_str)
    else
      return "/auth/facebook/most_annotate_share"
    end

  end

end
