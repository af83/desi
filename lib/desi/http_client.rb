# encoding: utf-8

require "net/https"
require "uri"
require "json"

module Desi

  class HttpClient
    def initialize(uri)
      @uri = URI(uri)

      case @uri.scheme
      when 'https'
        @http = ::Net::HTTP.new(@uri.host, 443)
        @http.use_ssl = true
        @http.verify_mode = ::OpenSSL::SSL::VERIFY_PEER
      when 'http'
        @http = ::Net::HTTP.new(@uri.host, 80)
      else
        raise ArgumentError, "Won't process scheme #{@uri.scheme}"
      end
    end

    def get(uri, limit = 5)
      raise "Too many HTTP redirects!" if limit <= 0

      response = @http.request(Net::HTTP::Get.new(uri))

      case response
        when Net::HTTPSuccess
          response
        when Net::HTTPRedirection
          fetch(response['location'], limit - 1)
        else
          raise response.error!
      end
    end
  end

end
