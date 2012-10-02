# encoding: utf-8

require "desi/http_client"
require "json"

module Desi
  class Upstream

    class Release < Struct.new(:archive_name, :description, :release_date, :download_url)
      def to_s
        archive_name
      end

      def name
        @name ||= archive_name.scan(/^(elasticsearch-.*?)\.tar\.gz$/).flatten.first
      end

      def version
        @version ||= archive_name.scan(/^elasticsearch-(.*?)\.tar\.gz$/).flatten.first
      end

      def ===(name_or_version)
        name_or_version == version || name_or_version == name || name_or_version == "v#{version}"
      end

      def <=>(other)
        other.release_date <=> other.release_date
      end
    end

    def initialize(opts = {})
      @client = opts.fetch(:http_client_factory, Desi::HttpClient).new('https://api.github.com/')
    end

    def releases
      @releases ||= fetch_releases.
        select {|v| v['content_type'] == 'application/gzip' }.
        map {|v| Release.new(v['name'], v['description'], v['created_at'], v['html_url']) }.
        sort
    end

    def latest_release
      releases.first
    end

    def find_release(name_or_version)
      releases.detect {|r| r === name_or_version }
    end

    private

    def fetch_releases
      JSON.parse @client.get('/repos/elasticsearch/elasticsearch/downloads').body
    end

  end
end
