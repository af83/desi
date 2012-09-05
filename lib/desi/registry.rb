# encoding: utf-8

require "desi/http_client"

module Desi
  class Registry

    class Version < Struct.new(:name, :description, :release_date, :download_url)
      def to_s
        self.name
      end
    end

    def initialize
      @client = Desi::HttpClient.new('https://api.github.com/')
    end

    def releases
      @releases ||= fetch_releases.
        select {|v| v['content_type'] == 'application/gzip' }.
        sort {|a,b| b["name"] <=> a['name'] }.
        map {|v| Version.new(v['name'], v['description'], v['created_at'], v['html_url']) }
    end

    def latest_release
      releases.first
    end

    private

    def fetch_releases
      JSON.parse @client.get('/repos/elasticsearch/elasticsearch/downloads').body
    end

  end
end
