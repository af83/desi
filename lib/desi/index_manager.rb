# encoding: utf-8

require "desi/http_client"

module Desi
  class IndexManager

    def initialize(opts = {})
      @host = opts.fetch(:host, 'http://127.0.0.1:9200')
      @verbose = opts[:verbose]
      @client = Desi::HttpClient.new(@host)
    end


    def list(pattern = nil)
      pattern = Regexp.new(pattern || '.*')

      puts "Indices from host #{@client.uri} matching the pattern #{pattern.inspect}\n\n" if @verbose

      list = indices(pattern).sort
      list.each {|i| puts i } if @verbose
      list
    end

    def delete!(pattern)
      warn "You must provide a pattern" and exit if pattern.nil?

      puts "The following indices from host #{@client.uri} are now deleted" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.delete(index)
        puts " * #{index}" if @verbose
      end
    end

    def empty!(pattern)
      warn "You must provide a pattern" and exit if pattern.nil?

      puts "The following indices from host #{@client.uri} are now emptied" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.delete("#{index}/_query?q=*")
        puts " * #{index}" if @verbose
      end
    end

    private

    def indices(pattern)
      JSON.parse(@client.get('_status').body)["indices"].keys.select {|i|
              i =~ pattern
      }
    end

  end
end
