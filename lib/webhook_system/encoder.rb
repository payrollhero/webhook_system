# frozen_string_literal: true

module WebhookSystem

  # Class in charge of encoding and decoding encrypted payload
  module Encoder
    # Given a secret string, encode the passed payload to json
    # encrypt it, base64 encode that, and wrap it in its own json wrapper
    #
    # @param [String] secret_string some secret string
    # @param [Object#to_json] payload Any object that responds to to_json
    # @return [String] The encoded string payload (its a JSON string)
    def self.encode(secret_string, payload, format:)
      response_hash = Payload.encode(payload, secret: secret_string, format: format)
      payload_string = JSON.generate(response_hash)
      signature = hub_signature(payload_string, secret_string)
      [payload_string, { 'X-Hub-Signature' => signature, 'Content-Type' => content_type_for_format(format) }]
    end

    # Given a secret string, and an encrypted payload, unwrap it, bas64 decode it
    # decrypt it, and JSON decode it
    #
    # @param [String] secret_string some secret string
    # @param [String] payload_string String as returned from #encode
    # @return [Object] return the JSON decode of the encrypted payload
    def self.decode(secret_string, payload_string, headers = {})
      signature = headers['X-Hub-Signature']
      format = format_for_content_type(headers.fetch('Content-Type'))

      payload_signature = hub_signature(payload_string, secret_string)
      if signature && signature != payload_signature
        raise DecodingError, 'signature mismatch'
      end

      Payload.decode(payload_string, secret: secret_string, format: format)
    end

    class << self
      private

      def content_type_format_map
        {
          'base64+aes256' => 'application/json; base64+aes256',
          'json' => 'application/json'
        }
      end

      def format_for_content_type(content_type)
        content_type_format_map.invert.fetch(content_type)
      end

      def content_type_for_format(format)
        content_type_format_map.fetch(format)
      end

      def hub_signature(payload_string, secret)
        'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_string)
      end
    end
  end

  module Payload
    class << self
      def encode(payload, secret:, format:)
        case format
        when 'base64+aes256'
          encode_aes(payload, secret)
        when 'json'
          payload
        else
          raise ArgumentError, "don't know how to handle: #{payload['format']} payload"
        end
      end

      def decode(response_body, secret:, format:)
        payload = JSON.load(response_body)

        case format
        when 'base64+aes256'
          decode_aes(payload, secret)
        when 'json'
          payload
        else
          raise ArgumentError, "don't know how to handle: #{payload['format']} payload"
        end
      end

      private

      def encode_aes(payload, secret)
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        iv = cipher.random_iv
        cipher.key = key_from_secret(iv, secret)
        encoded = cipher.update(payload.to_json) + cipher.final

        {
          format: 'base64+aes256',
          payload: Base64.encode64(encoded),
          iv: Base64.encode64(iv),
        }
      end

      def decode_aes(payload, secret)
        encoded = Base64.decode64(payload['payload'])
        iv = Base64.decode64(payload['iv'])

        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.decrypt
        cipher.iv = iv
        cipher.key = key_from_secret(iv, secret)
        decoded = cipher.update(encoded) + cipher.final

        JSON.load(decoded)
      rescue OpenSSL::Cipher::CipherError
        raise DecodingError, 'Decoding Failed, probably mismatched secret'
      end

      def key_from_secret(iv, secret_string)
        OpenSSL::PKCS5.pbkdf2_hmac(secret_string, iv, 100_000, 256 / 8, 'SHA256')
      end
    end
  end
end
