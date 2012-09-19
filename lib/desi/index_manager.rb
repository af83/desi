# encoding: utf-8

require "desi/http_client"

module Desi

  # Performs some simple index-related operations on a local or distance
  # Elastic Search cluster
  class IndexManager

    # Initializes a Desi::IndexManager instance
    #
    # @param       [#to_hash]  opts                             Hash of extra opts
    #
    # @option opts [#to_s]     :host ('http://127.0.0.1:9200')  Host to manage indices for
    # @option opts [Boolean]   :verbose   (nil) Whether to output the actions' result
    #                                           on STDOUT
    # @option opts [#new]      :http_client_factory (Desi::HttpClient) HTTP transport class
    #                                                                  to use
    #
    # @note The +:http_client_factory+ should return an instance that responds
    #       to #get and #delete
    # @return [undefined]
    #
    # @api public
    def initialize(opts = {})
      @host = opts.fetch(:host, 'http://127.0.0.1:9200')
      @verbose = opts[:verbose]
      @client = opts.fetch(:http_client_factory, Desi::HttpClient).new(@host)
    end


    # List index names for the specified cluster
    #
    # You can restrict the list using a regular expression pattern. (The default
    # pattern being +/.*/+, all releases will be returned if you do not
    # specify anything.)
    #
    # @param   [#to_s]          pattern ('.*') Regexp pattern used to restrict the selection
    # @return  [Array<String>]                 List of index names of the ES cluster
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @example List all indices whose name begins with "foo"
    #    Desi::IndexManager.new.list('^foo') #=> ["foo1", "foo2", "foo3"]
    #
    # @api  public
    def list(pattern = '.*')
      pattern = Regexp.new(pattern || '.*')

      puts "Indices from host #{@client.uri} matching the pattern #{pattern.inspect}\n\n" if @verbose

      list = indices(pattern).sort
      list.each {|i| puts i } if @verbose
      list
    end

    # Delete all indices matching the specified pattern
    #
    # @param   [#to_s]          pattern  Regexp pattern used to restrict the selection
    # @return  [undefined]
    #
    # @note No confirmation is needed, so beware!
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @example Delete all indices whose name begins with "test"
    #    Desi::IndexManager.new.delete!('^test') #=> nil
    #
    # @api  public
    def delete!(pattern)
      warn "You must provide a pattern" and exit if pattern.nil?

      puts "The following indices from host #{@client.uri} are now deleted" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.delete(index)
        puts " * #{index}" if @verbose
      end
    end

    # Empty (remove all records) from indices matching the specified pattern
    #
    # @param   [#to_s]          pattern  Regexp pattern used to restrict the selection
    # @return  [undefined]
    #
    # @note No confirmation is needed, so beware!
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @example Empty all indices whose name begins with "log"
    #    Desi::IndexManager.new.empty!('^log') #=> nil
    #
    # @api  public
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
