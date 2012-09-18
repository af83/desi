# encoding: utf-8

require "net/https"
require "addressable/uri"
require "json"

module Desi

  class HttpClient

    attr_reader :uri

    def initialize(host_string)
      @uri = to_uri(host_string)

      case @uri.scheme
      when 'https'
        @http = ::Net::HTTP.new(@uri.host, 443)
        @http.use_ssl = true
        @http.verify_mode = ::OpenSSL::SSL::VERIFY_PEER
      when 'http'
        @http = ::Net::HTTP.new(@uri.host, @uri.port)
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

    private

    def to_uri(host_string)
      scheme, host, port = ['http', '127.0.0.1', 9200]

      %r{(?<scheme>(https?|))(?:\:\/\/|)(?<host>[^:]+):?(?<port>\d+)/?}.match(host_string) do |m|
        scheme = m[:scheme] unless m[:scheme].empty?
        host = m[:host] unless m[:host].empty?
        port = m[:port] unless m[:port].empty?
      end

      Addressable::URI.new(scheme: scheme, host: host, port: port)
    end
  end

end
