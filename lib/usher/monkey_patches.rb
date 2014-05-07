# encoding: UTF-8

require 'active_support/deprecation'
require 'active_support/core_ext/object/blank'

module Usher
  class MonkeyPatch < Module
    private
    def included(base)
      base.module_eval(&@patch)
    end

    def initialize(&patch)
      @patch = patch
    end
  end # MonkeyPatch

  module MonkeyPatches
    MessageVerifier = MonkeyPatch.new do
      def initialize(secret, options = {})
        unless options.is_a?(Hash)
          ActiveSupport::Deprecation.warn "The second parameter should be an options hash. Use :digest => 'algorithm' to specify the digest algorithm."
          options = { :digest => options }
        end
      
        @secret = secret
        @digest = options[:digest] || 'SHA1'
        @serializer = options[:serializer] || Marshal
      end
      
      def verify(signed_message)
        raise InvalidSignature if signed_message.blank?
      
        data, digest = signed_message.split("--")
        data = URI.decode(data) if data
        if data.present? && digest.present? && secure_compare(digest, generate_digest(data))
          begin
            @serializer.load(::Base64.decode64(data))
          rescue ArgumentError => argument_error
            raise InvalidSignature if argument_error.message =~ %r{invalid base64}
            raise
          rescue MessagePack::MalformedFormatError
            {}
          end
        else
          raise InvalidSignature
        end
      end
      
      def generate(value)
        data = ::Base64.strict_encode64(@serializer.dump(value))
        "#{data}--#{generate_digest(data)}"
      end
      
      private
      # constant-time comparison algorithm to prevent timing attacks
      def secure_compare(a, b)
        return false unless a.bytesize == b.bytesize
    
        l = a.unpack "C#{a.bytesize}"
    
        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res == 0
      end
    
      def generate_digest(data)
        require 'openssl' unless defined?(OpenSSL)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.const_get(@digest).new, @secret, data)
      end
    end # MessageVerifier
     
    # Make signed cookies use Usher as serializer instead of Marshal
    SignedCookieJar = MonkeyPatch.new do
      def initialize(parent_jar, secret, options = {})
        if String === secret
          ensure_secret_secure(secret)
        else
          @options = options
          key_generator = secret
          secret = key_generator.generate_key(@options[:signed_cookie_salt])
        end
        
        @parent_jar = parent_jar
        @verifier   = ActiveSupport::MessageVerifier.new(secret, serializer: Usher)
      end
    end # SignedCookieJar
  end # MonkeyPatches
end # Usher