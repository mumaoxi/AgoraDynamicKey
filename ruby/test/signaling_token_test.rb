require 'rspec'
require '../src/signaling_token'
account = "2882341273"
app_id = "970CA35de60c44645bbae8a215061b33"
app_certificate = "5CFd2fd1755d40ecb72977518be15d3b"
now = 1514133234
valid_time_in_seconds = 3600 * 24
expired_ts_in_seconds = now + valid_time_in_seconds

describe 'SignalingTokenTest' do
  it 'gen signaling token' do
    expected = "1:970CA35de60c44645bbae8a215061b33:1514219634:82539e1f3973bcfe3f0d0c8993e6c051"
    actual = SignalingToken.generate_signaling_token(
        account, app_id, app_certificate, expired_ts_in_seconds)
    expect(actual).equal? expected
  end
end


