# encoding: utf-8

require "pathname"
require "desi/local_install"
require "desi/http_client"
require "uri"

module Desi
  class Downloader

    def initialize(destination_dir = nil, host = 'http://cloud.github.com/')
      @destination_dir = Pathname(destination_dir || Desi::LocalInstall.new)
      @host = URI(host)
      @client = Desi::HttpClient.new(@host)
    end

    def download!(version, opts = {})
      path = "/downloads/elasticsearch/elasticsearch/#{version.name}"
      destination_name = @destination_dir.join File.basename(version.name)

      raise "ERROR: File #{destination_name} already present!" if destination_name.exist?

      puts "  * fetching release #{version} from #{@host + path}"

      File.open(destination_name, 'w') {|f| f << @client.get(path).body }

      destination_name
    end

  end
end
