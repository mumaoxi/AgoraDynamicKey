require '../src/signaling_token'

account = "2882341273"
app_id = "970CA35de60c44645bbae8a215061b33"
app_certificate = "5CFd2fd1755d40ecb72977518be15d3b"
now = Time.now.to_i
valid_time_seconds = 3600 * 24
expired_ts_seconds = now + valid_time_seconds

puts "Signal Token:", SignalingToken.generate_signaling_token(account, app_id, app_certificate, expired_ts_seconds)
