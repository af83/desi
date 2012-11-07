# encoding: utf-8

require "json"
require "desi/cocaine"
require "ostruct"
require "desi/http_client"
require "desi/local_install"

module Desi

  # The ProcessManager will start, stop and restart a local Elastic Search node
  # instance, in addition to reporting its status
  #
  # @example Start up the instance and check its status
  #   Desi::ProcessManager.new.start.status #=> "OK. Elastic Search cluster 'elasticsearch' (v0.19.9) is running on 1 node(s) with status green"
  #
  # @example Retrieve the currently running cluster's version
  #   Desi::ProcessManager.new.running_version #=> "0.19.9"
  #
  # @example Retrieve a distant cluster's version
  #   Desi::ProcessManager.new(host: "http://somewhere.com:9200").running_version #=> "0.18.5"
  #
  class ProcessManager

    def initialize(opts = {})
      @host = opts.fetch(:host, 'http://127.0.0.1:9200')
      @verbose = opts[:verbose]
      @local_install = LocalInstall.new
      @client = opts.fetch(:http_client_factory, Desi::HttpClient).new(@host)
    end

    # Start the cluster
    #
    # This will be a no-op if the cluster is already started.
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @return [self]
    #
    # @api  public
    def start
      if cluster_ready?
        puts "ES cluster is already running" if @verbose
      else
        puts " * Elastic Search #{running_version} started" if start_cluster && @verbose
      end
      self
    end

    # Restart the cluster
    #
    # Stop the cluster (if its up) and start it again.
    #
    # @note We use the pidfile to determine if the cluster is up. If a node was
    #       started with another tool, you may end up with more than 1 node
    #       running.
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @return [self]
    #
    # @api  public
    def restart
      puts " * (Re)starting cluster" if @verbose
      stop if has_pid?
      puts " * Elastic Search #{running_version} started" if start_cluster && @verbose
      self
    end

    # Stop the cluster
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @return [self]
    #
    # @api  public
    def stop
      if pid
        puts " * Will stop instance with pid #{pid}" if @verbose
        stop_cluster
      else
        puts " * No pidfile detected!. Won't stop" if @verbose
      end
      self
    end

    # Get information about the cluster's status
    #
    #   Desi::ProcessManager.new.status #=> "OK. Elastic Search cluster 'elasticsearch' (v0.19.9) is running on 1 node(s) with status green"
    #
    # @note This method will also output its result on STDOUT if +@verbose+ is
    #       true
    #
    # @return [String]
    #
    # @api  public
    def status
      if version = running_version
        msg = "OK. Elastic Search cluster '#{cluster_health.cluster_name}' (v#{version}) is running on #{cluster_health.number_of_nodes} node(s) with status #{cluster_health.status}"
      else
        msg = "KO. No Elastic Search instance was found running on #{@host}"
      end
      puts msg if @verbose
      msg
    end

    # Whether the pidfile actually holds a PID
    #
    # @return [Boolean]
    def has_pid?
      pid && !pid.empty?
    end

    # PID as retrieved from the pidfile
    #
    # @return [String]
    def pid
      @pid ||= File.read(pidfile) if pidfile.exist?
    end

    # Release number of the currently running cluster
    #
    # @example
    #   Desi::ProcessManager.new.running_version #=> "0.19.9"
    #
    #
    # @return [String,nil]
    def running_version
      begin
        JSON.parse(@client.get('/').body)["version"]["number"]
      rescue
        nil
      end
    end

    protected

    # Return cluster health data straight from the cluster
    #
    # see
    # http://www.elasticsearch.org/guide/reference/api/admin-cluster-health.html
    # for further information on the response's structure
    #
    # @return [Hash]
    def cluster_health
      @cluster_health ||= OpenStruct.new(JSON.parse(@client.get('/_cluster/health').body))
    end

    private

    def wait_until_cluster_becomes_ready(max_wait = 10, step = 0.5)
      wait_for(max_wait, step) { cluster_ready? }
    end

    def wait_until_cluster_is_down(max_wait = 5, step = 0.3)
      wait_for(max_wait, step) { !cluster_ready? }
    end

    def start_cluster
      line = Cocaine::CommandLine.new(@local_install.launcher.to_s, "-p :pidfile")
      line.run(pidfile: pidfile.to_s)

      unless wait_until_cluster_becomes_ready
        raise "Cluster still not ready after #{max_wait} seconds!"
      end
    rescue Cocaine::CommandNotFoundError
      warn "#{@local_install.launcher} could not be found! Are you sure that Elastic Search is already installed?"
      false
    else
      true
    end

    def stop_cluster
      kill!

      unless wait_until_cluster_is_down
        raise "Strange. Cluster seems still up after #{max_wait} seconds!"
      end
    end

    def kill!
      Process.kill("HUP", Integer(pid)) if has_pid?
    end

    def pidfile
      @pidfile ||= Pathname(@local_install.pidfile)
    end

    def cluster_ready?
      begin
        JSON.parse(@client.get('/').body)["ok"]
      rescue
        false
      end
    end

    def wait_for(max_wait = 10, step = 0.5, &condition)
      delay = 0
      until delay > max_wait || condition.call
        sleep step
        delay += step
      end
      delay < max_wait
    end


  end
end
