module ApplicationHelper
  def social_auth_path(provider, status, user_id=nil)
    if !user_id.nil?
      "/auth/#{provider.to_s}?status=" + status.to_s + "&user_id=" + user_id.to_s
    else
      "/auth/#{provider.to_s}?status=" + status.to_s
    end
  end

end
