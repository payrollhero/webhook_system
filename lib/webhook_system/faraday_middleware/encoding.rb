# This is taken from https://github.com/ma2gedev/faraday-encoding,
# all credits for this goes to Takayuki Matsubara (takayuki.1229+github@gmail.com).
# We should be able to switch to the original gem when
# this PR (https://github.com/ma2gedev/faraday-encoding/pull/2) is merged.
module Faraday
  class Faraday::Encoding < Faraday::Middleware
    def call(environment)
      @app.call(environment).on_complete do |env|
        @content_charset = nil
        if /;\s*charset=\s*(.+?)\s*(;|$)/.match(env[:response_headers][:content_type])
          encoding = $1
          encoding = 'utf-8' if encoding == 'utf8'
          @content_charset = ::Encoding.find encoding rescue nil
        end
        env[:body].force_encoding @content_charset if @content_charset
      end
    end
  end
end

Faraday::Response.register_middleware :encoding => Faraday::Encoding
