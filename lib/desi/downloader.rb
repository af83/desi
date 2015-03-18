# encoding: utf-8

require "pathname"
require "desi/local_install"
require "desi/http_client"
require "uri"

module Desi
  class Downloader

    def initialize(opts = {})
      @destination_dir = Pathname(opts.fetch(:destination_dir, Desi::LocalInstall.new))
      @host = URI(opts.fetch(:host, 'https://download.elasticsearch.org/'))
      @client = opts.fetch(:http_client_factory, Desi::HttpClient).new(@host)
      @verbose = opts[:verbose]
    end

    def download!(version, opts = {})
      path = "/elasticsearch/elasticsearch/#{version.filename}"
      destination_name = @destination_dir.join File.basename(version.filename)

      raise "ERROR: File #{destination_name} already present!" if destination_name.exist?

      puts "  * fetching release #{version} from #{@host + path}" if @verbose

      @client.get_file(path, destination_name)

      destination_name
    end

  end
end
