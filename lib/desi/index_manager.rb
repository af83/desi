# encoding: utf-8

require "desi/http_client"
require "desi/configuration"

module Desi

  # Performs some simple index-related operations on a local or distance
  # Elastic Search cluster
  class IndexManager

    class Index
      attr_reader :name, :number_of_documents, :aliases, :state, :number_of_documents

      def initialize(name, state_data, status_data)
        @name = name
        @number_of_documents = status_data["docs"]["num_docs"] if status_data && status_data["docs"]
        @aliases = []

        if state_data
          @aliases = state_data['aliases']
          @state = state_data['state']
        end
      end

      def to_s
        name
      end

      def inspect
        "#{name} (#{number_of_docs_label})#{aliases_label}"
      end

      def aliased?
        !(aliases.nil? || aliases.empty?)
      end

      def <=>(other)
        name <=> other.name
      end

      def open?
        state == "open"
      end

      def closed?
        state == "close"
      end

      private

      def number_of_docs_label
        closed? ? 'CLOSED' : "#{number_of_documents} docs"
      end

      def aliases_label
        aliased? ? ". Aliases: #{aliases.join(', ')}" : nil
      end
    end

    # Initializes a Desi::IndexManager instance
    #
    # @param       [#to_hash]  opts                             Hash of extra opts
    #
    # @option opts [#to_s]     :host ('http://localhost:9200')  Host to manage indices for
    # @option opts [Boolean]   :verbose   (nil) Whether to output the actions' result
    #                                           on STDOUT
    # @option opts [#new]      :http_client_factory (Desi::HttpClient) HTTP transport class
    #                                                                  to use
    #
    # @note The +:http_client_factory+ should return an instance that responds
    #       to #get and #delete
    # @return [void]
    #
    # @api public
    def initialize(opts = {})
      @host = to_uri(opts.fetch(:host) { Desi.configuration.server })
      @verbose = opts[:verbose]
      @outputter = opts.fetch(:outputter, Kernel)
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

      @outputter.puts "Indices from host #{@host} matching the pattern #{pattern.inspect}\n\n" if @verbose

      list = indices(pattern).sort
      list.each {|i| @outputter.puts i.inspect } if @verbose
      list
    end

    # Delete all indices matching the specified pattern
    #
    # @param   [#to_s]          pattern  Regexp pattern used to restrict the selection
    # @return  [void]
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

      @outputter.puts "The following indices from host #{@host} are now deleted" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.delete("/#{index}")
        @outputter.puts " * #{index.inspect}" if @verbose
      end
    end

    # Close all indices matching the specified pattern
    #
    # @param   [#to_s]          pattern  Regexp pattern used to restrict the selection
    # @return  [void]
    #
    # @note No confirmation is needed, so beware!
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @example Close all indices whose name begins with "test"
    #    Desi::IndexManager.new.close!('^test') #=> nil
    #
    # @api  public
    def close!(pattern)
      warn "You must provide a pattern" and exit if pattern.nil?

      @outputter.puts "The following indices from host #{@host} are now closed" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.post("/#{index}/_close")
        @outputter.puts " * #{index.inspect}" if @verbose
      end
    end

    # Empty (remove all records) from indices matching the specified pattern
    #
    # @param   [#to_s]          pattern  Regexp pattern used to restrict the selection
    # @return  [void]
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

      @outputter.puts "The following indices from host #{@host} are now emptied" if @verbose

      indices(Regexp.new(pattern)).each do |index|
        @client.delete("/#{index}/_query?q=*")
        @outputter.puts " * #{index}" if @verbose
      end
    end

    private

    def indices(pattern)
      cluster_state = JSON.parse(@client.get('/_cluster/state').body)
      status = JSON.parse(@client.get('/_status').body)

      cluster_state["metadata"]["indices"].map {|k, v|
        if k =~ pattern
          Index.new(k, v, status['indices'][k])
        end
      }.compact
    end

    def to_uri(host_string)
      scheme, host, port = ['http', 'localhost', 9200]

      %r{(?<scheme>(https?|))(?:\:\/\/|)(?<host>[^:]*?):?(?<port>\d*)/?$}.match(host_string.to_s) do |m|
        scheme = m[:scheme] unless m[:scheme].empty?
        host = m[:host] unless m[:host].empty?
        port = m[:port] unless m[:port].empty?
      end

      "#{scheme}://#{host}:#{port}"
    end

  end
end
