module WebhookSystem

  # Class in charge of encoding and decoding encrypted payload
  module Encoder
    class << self
      # Given a secret string, encode the passed payload to json
      # encrypt it, base64 encode that, and wrap it in its own json wrapper
      #
      # @param [String] secret_string some secret string
      # @param [Object#to_json] payload Any object that responds to to_json
      # @return [String] The encoded string payload (its a JSON string)
      def encode(secret_string, payload)
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        iv = cipher.random_iv
        cipher.key = key_from_secret(iv, secret_string)
        encoded = cipher.update(payload.to_json) + cipher.final
        Payload.encode(encoded, iv)
      end

      # Given a secret string, and an encrypted payload, unwrap it, bas64 decode it
      # decrypt it, and JSON decode it
      #
      # @param [String] secret_string some secret string
      # @param [String] payload String as returned from #encode
      # @return [Object] return the JSON decode of the encrypted payload
      def decode(secret_string, payload)
        encoded, iv = Payload.decode(payload)
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.decrypt
        cipher.iv = iv
        cipher.key = key_from_secret(iv, secret_string)
        decoded = cipher.update(encoded) + cipher.final
        JSON.load(decoded)
      rescue OpenSSL::Cipher::CipherError
        raise DecodingError, 'Decoding Failed, probably mismatched secret'
      end

      private

      def key_from_secret(iv, secret_string)
        OpenSSL::PKCS5.pbkdf2_hmac(secret_string, iv, 100_000, 256 / 8, 'SHA256')
      end
    end
  end

  # private class to just wrap the outer wrapping of the response format
  # not exposed to the outside
  # :nodoc:
  module Payload
    class << self
      def encode(raw_encrypted_data, iv)
        JSON.dump(
          'format' => 'base64+aes256',
          'payload' => Base64.encode64(raw_encrypted_data),
          'iv' => Base64.encode64(iv),
        )
      end

      def decode(payload_string)
        payload = JSON.load(payload_string)
        unless payload['format'] == 'base64+aes256'
          raise ArgumentError, 'only know how to handle base64+aes256 payloads'
        end
        [Base64.decode64(payload['payload']), Base64.decode64(payload['iv'])]
      end
    end
  end
end
