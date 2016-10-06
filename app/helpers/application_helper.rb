module ApplicationHelper
  def social_auth_path(provider, status, user_id=nil)
    if !user_id.nil?
      "/auth/#{provider.to_s}?status=" + status.to_s + "&user_id=" + user_id.to_s
    else
      "/auth/#{provider.to_s}?status=" + status.to_s
    end
  end

  def facebook_most_annotated_share_path(lang, num, from_date, to_date, user_id=nil)
    if user_id.nil?
      params_str = ""

      params_str = lang.nil? ? params_str : params_str+"lang="+lang.to_s
      params_str = num.nil? ? params_str : params_str+"&num="+num.to_s
      params_str = from_date.nil? ? params_str : params_str+"&from_date="+from_date.to_s
      params_str = to_date.nil? ? params_str : params_str+"&to_date="+to_date.to_s

      host_url = request.protocol + request.host_with_port
      return 'https://www.facebook.com/dialog/feed?'+
            'app_id=' + FACEBOOK_KEY.to_s +
            '&display=popup&amp;caption=Most%20annotated%20articles' +
            '&link=' + url_encode(host_url + '/show_most_annotated_urls?'+ params_str) +
            '&redirect_uri=' + url_encode(host_url + '/show_most_annotated_urls?'+ params_str)
    else
      return "/auth/facebook/most_annotate_share"
    end

  end

end
