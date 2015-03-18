# encoding: utf-8

require "desi/http_client"
require "json"
require "semantic"

module Desi
  class Upstream

    class Release < Struct.new(:version_name, :download_url)
      def to_s
        name
      end

      def name
        "elasticsearch-#{version}"
      end

      def filename
        "elasticsearch-#{version}.tar.gz"
      end

      def ===(name_or_version)
        name_or_version == version || name_or_version == name || name_or_version == "v#{version}"
      end

      def <=>(other)
        other.sortable_version <=> sortable_version
      end

      def version
        version_name.gsub(/^v/, '')
      end

      protected

      def sortable_version
        @sortable_version ||= Semantic::Version.new(version.sub(%r{.(beta|alpha|rc)}i, '-\1'))
      end
    end

    def initialize(opts = {})
      @client = opts.fetch(:http_client_factory, Desi::HttpClient).new('https://api.github.com/')
    end

    def releases
      @releases ||= fetch_tags.
        map {|v| Release.new(v['name'], v['tarball_url']) }.
        sort
    end

    def latest_release
      releases.first
    end

    def find_release(name_or_version)
      releases.detect {|r| r === name_or_version }
    end

    private

    def fetch_tags
      JSON.parse @client.get('/repos/elastic/elasticsearch/tags').body
    end

  end
end
