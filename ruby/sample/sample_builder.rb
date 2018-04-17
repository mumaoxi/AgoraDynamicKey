require '../src/access_token'
require '../src/simple_token_builder'
app_id = "970CA35de60c44645bbae8a215061b33"
app_certificate = "5CFd2fd1755d40ecb72977518be15d3b"
channel_name = "7d72365eb983485397e3e3f9d460bdda"
uid = 2882341273
expire_timestamp = 0

builder = SimpleTokenBuilder::SimpleTokenBuilder.new(app_id, app_certificate, channel_name, uid)
builder.init_privileges(SimpleTokenBuilder::ROLE_ATTENDEE)
builder.set_privilege(AccessToken::K_JOIN_CHANNEL, expire_timestamp)
builder.set_privilege(AccessToken::K_PUBLISH_AUDIO_STREAM, expire_timestamp)
builder.set_privilege(AccessToken::K_PUBLISH_VIDEO_STREAM, expire_timestamp)
builder.set_privilege(AccessToken::K_PUBLISH_DATA_STREAM, expire_timestamp)

result = builder.build_token
print result