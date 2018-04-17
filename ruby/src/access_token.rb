# coding: utf-8
require 'openssl'
require 'base64'
require 'digest/hmac'
require 'zlib'
module AccessToken
  module_function
  K_JOIN_CHANNEL = 1
  K_PUBLISH_AUDIO_STREAM = 2
  K_PUBLISH_VIDEO_STREAM = 3
  K_PUBLISH_DATA_STREAM = 4
  K_PUBLISH_AUDIO_CDN = 5
  K_PUBLISH_VIDEO_CDN = 6
  K_REQUEST_PUBLISH_AUDIO_STREAM = 7
  K_REQUEST_PUBLISH_VIDEO_STREAM = 8
  K_REQUEST_PUBLISH_DATA_STREAM = 9
  K_INVITE_PUBLISH_AUDIO_STREAM = 10
  K_INVITE_PUBLISH_VIDEO_STREAM = 11
  K_INVITE_PUBLISH_DATA_STREAM = 12
  K_ADMINISTRATE_CHANNEL = 101

  VERSION_LENGTH = 3
  APP_ID_LENGTH = 32

  def get_version
    '006'
  end

  def pack_uint16(x)
    [x].pack('<S')
  end

  def pack_uint32(x)
    [x].pack('<I')
  end

  def pack_int32(x)
    [x].pack('<i')
  end

  def pack_string(string)
    pack_uint16(string.length) + string
  end

  def pack_map(m)
    ret = pack_uint16(m.size)
    m.each do |k, v|
      ret += pack_uint16(k.to_i) + pack_string(v.to_s)
    end
    ret
  end

  def pack_map_uint32(m)
    ret = pack_uint16(m.size)
    m.each do |k, v|
      ret += pack_uint16(k.to_i) + pack_uint32(v.to_i)
    end
    ret
  end

  class ReadByteBuffer
    attr_accessor :buffer
    attr_accessor :position

    def initialize(bytes)
      @buffer = bytes
      @position = 0
    end

    def unpack_uint16
      len = [0].pack('<S').length
      buff = self.buffer[self.position, self.position + len]
      ret = buff.unpack('<S')[0]
      self.position += len
      ret
    end

    def unpack_uint32
      len = [0].pack('<I').length
      buff = self.buffer[self.position, self.position + len]
      ret = buff.unpack('<I')[0]
      self.position += len
      ret
    end

    def unpack_string
      strlen = self.unpack_uint16
      buff = self.buffer[self.position, self.position + strlen]
      ret = buff.unpack("<#{strlen}s")[0]
      self.position += strlen
      ret
    end

    def unpack_map_uint32
      message = {}
      maplen = self.unpack_uint16
      maplen.times.each do
        key = self.unpack_uint16
        value = self.unpack_uint32
        message[key] = value
      end
      message
    end

  end

  def unpack_content(buff)
    readbuf = ReadByteBuffer.new(buff)
    signature = readbuf.unpack_string
    crc_channel_name = readbuf.unpack_uint32
    crc_uid = readbuf.unpack_uint32
    m = readbuf.unpack_string
    [signature, crc_channel_name, crc_uid, m]
  end

  def unpack_messages(buff)
    readbuf = ReadByteBuffer.new(buff)
    salt = readbuf.unpack_uint32
    ts = readbuf.unpack_uint32
    messages = readbuf.unpack_map_uint32
    [salt, ts, messages]
  end

  class AccessToken
    attr_accessor :app_id
    attr_accessor :app_certificate
    attr_accessor :channel_name
    attr_accessor :ts
    attr_accessor :salt
    attr_accessor :messages
    attr_accessor :uid_str

    def initialize(app_id, app_certificate, channel_name, uid)
      @app_id = app_id
      @app_certificate = app_certificate
      @channel_name = channel_name
      @ts = Time.now.to_i + 24 * 3600
      @salt = rand(99999999)
      @messages = {}
      @uid_str = uid == 0 ? '' : "#{uid}"
    end

    def add_privilege(privilege, expire_timestamp)
      self.messages[privilege] = expire_timestamp
    end

    def from_string(origin_token)
      dk6version = ::AccessToken.get_version
      origin_version = origin_token[VERSION_LENGTH]
      unless origin_version == dk6version
        return false
      end
      origin_app_id = origin_token[VERSION_LENGTH, VERSION_LENGTH + APP_ID_LENGTH]
      origin_content = origin_token[VERSION_LENGTH + APP_ID_LENGTH, origin_token.length]
      origin_content_decoded = Base64.decode64(origin_content)
      signature, crc_channel_name, crc_uid, m = ::AccessToken.unpack_content(origin_content_decoded)
      self.salt, self.ts, self.messages = ::AccessToken.unpack_messages(m)
    end

    def build
      self.messages = self.messages.sort.to_h
      m = ::AccessToken.pack_uint32(self.salt) + ::AccessToken.pack_uint32(self.ts) + ::AccessToken.pack_map_uint32(self.messages)

      val = self.app_id + self.channel_name + self.uid_str + m
      signature = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), self.app_certificate, val)
      crc_channel_name = Zlib::crc32(self.channel_name) & 0xffffffff
      crc_uid = Zlib::crc32(self.uid_str) & 0xffffffff

      content = ::AccessToken.pack_string(signature) +
          ::AccessToken.pack_uint32(crc_channel_name) +
          ::AccessToken.pack_uint32(crc_uid) +
          ::AccessToken.pack_string(m)

      puts "content:#{content}\n"

      version = ::AccessToken.get_version
      version + self.app_id + Base64.encode64(content).gsub(/\n/,'')
    end
  end
end