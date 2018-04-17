# coding: utf-8
require_relative 'access_token'
module SimpleTokenBuilder
  ROLE_ATTENDEE = 1
  ROLE_PUBLISHER = 2
  ROLE_SUBSCRIBER = 3
  ROLE_ADMIN = 4

  ATTENDEE_PRIVILEGES = {
      AccessToken::K_JOIN_CHANNEL => 0,
      AccessToken::K_PUBLISH_AUDIO_STREAM => 0,
      AccessToken::K_PUBLISH_VIDEO_STREAM => 0,
      AccessToken::K_PUBLISH_DATA_STREAM => 0
  }.sort.to_h

  PUBLISHER_PRIVILEGES = {
      AccessToken::K_JOIN_CHANNEL => 0,
      AccessToken::K_PUBLISH_AUDIO_STREAM => 0,
      AccessToken::K_PUBLISH_VIDEO_STREAM => 0,
      AccessToken::K_PUBLISH_DATA_STREAM => 0,
      AccessToken::K_PUBLISH_AUDIO_CDN => 0,
      AccessToken::K_PUBLISH_VIDEO_CDN => 0,
      AccessToken::K_INVITE_PUBLISH_AUDIO_STREAM => 0,
      AccessToken::K_INVITE_PUBLISH_VIDEO_STREAM => 0,
      AccessToken::K_INVITE_PUBLISH_DATA_STREAM => 0
  }.sort.to_h

  SUBSCRIBER_PRIVILEGES = {
      AccessToken::K_JOIN_CHANNEL => 0,
      AccessToken::K_PUBLISH_AUDIO_STREAM => 0,
      AccessToken::K_PUBLISH_VIDEO_STREAM => 0,
      AccessToken::K_PUBLISH_DATA_STREAM => 0
  }.sort.to_h

  ADMIN_PRIVILEGES = {
      AccessToken::K_JOIN_CHANNEL => 0,
      AccessToken::K_PUBLISH_AUDIO_STREAM => 0,
      AccessToken::K_PUBLISH_VIDEO_STREAM => 0,
      AccessToken::K_PUBLISH_DATA_STREAM => 0,
      AccessToken::K_ADMINISTRATE_CHANNEL => 0
  }.sort.to_h

  ROLE_PRIVILEGES = {
      ROLE_ATTENDEE => ATTENDEE_PRIVILEGES,
      ROLE_PUBLISHER => PUBLISHER_PRIVILEGES,
      ROLE_SUBSCRIBER => SUBSCRIBER_PRIVILEGES,
      ROLE_ADMIN => ADMIN_PRIVILEGES
  }.sort.to_h

  class SimpleTokenBuilder
    attr_accessor :app_id
    attr_accessor :app_certificate
    attr_accessor :channel_name
    attr_accessor :uid
    attr_accessor :token

    def initialize(app_id, app_certificate, channel_name, uid)
      self.token = AccessToken::AccessToken.new(app_id, app_certificate, channel_name, uid)
    end

    def init_privileges(role)
      self.token.messages = ROLE_PRIVILEGES[role]
    end

    def init_token_builder(origin_token)
      self.token.from_string(origin_token)
    end

    def set_privilege(privilege, expire_timestamp)
      self.token.messages[privilege] = expire_timestamp
    end

    def remove_privilege(privilege)
      self.token.messages.pop(privilege)
    end

    def build_token
      self.token.build
    end
  end
end