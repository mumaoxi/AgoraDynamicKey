require 'digest/hmac'
module SignalingToken

  module_function

  def generate_signaling_token(
      account,
      app_id,
      app_certificate,
      expired_ts_in_seconds)
    version = "1"
    expired = "#{expired_ts_in_seconds}"
    content = account + app_id + app_certificate + expired
    md5 = Digest::MD5.new
    md5.update content
    md5sum = md5.hexdigest
    sprintf("%s:%s:%s:%s", version, app_id, expired, md5sum)
  end
end
