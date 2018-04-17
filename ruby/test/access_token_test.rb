require 'rspec'
require '../src/access_token'

app_id = "970CA35de60c44645bbae8a215061b33"
app_certificate = "5CFd2fd1755d40ecb72977518be15d3b"
channel_name = "7d72365eb983485397e3e3f9d460bdda"
uid = 2882341273
expire_timestamp = 1446455471
salt = 1
ts = 1111111

describe 'AccessTokenTest' do

  it 'normal uid test' do
    expected = "006970CA35de60c44645bbae8a215061b33IACV0fZUBw+72cVoL9eyGGh3Q6Poi8bgjwVLnyKSJyOXR7dIfRBXoFHlEAABAAAAR/QQAAEAAQCvKDdW"

    key = AccessToken::AccessToken.new(app_id, app_certificate, channel_name, uid)
    key.salt = salt
    key.ts = ts
    key.messages[AccessToken::K_JOIN_CHANNEL] = expire_timestamp

    result = key.build
    expect(result).equal? expected
  end

  it 'uid is 0 test' do
    expected = "006970CA35de60c44645bbae8a215061b33IACw1o7htY6ISdNRtku3p9tjTPi0jCKf9t49UHJhzCmL6bdIfRAAAAAAEAABAAAAR/QQAAEAAQCvKDdW"

    uid_zero = 0
    key = AccessToken::AccessToken.new(app_id, app_certificate, channel_name, uid_zero)
    key.salt = salt
    key.ts = ts
    key.messages[AccessToken::K_JOIN_CHANNEL] = expire_timestamp

    result = key.build
    expect(result).equal? expected
  end

end