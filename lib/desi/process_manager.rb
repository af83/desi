# encoding: utf-8

require "json"
require "cocaine"
require "ostruct"
require "desi/http_client"
require "desi/local_install"

module Desi
  class ProcessManager

    def initialize(opts = {})
      @host = opts.fetch(:host, 'http://127.0.0.1:9200')
      @verbose = opts[:verbose]
      @local_install = LocalInstall.new
      @client = opts.fetch(:http_client, Desi::HttpClient).new(@host) }
    end

    def start
      if cluster_ready?
        puts "ES cluster is already running" if @verbose
      else
        start_cluster
        puts " * Elastic Search #{running_version} started" if @verbose
      end
    end

    def restart
      puts " * (Re)starting cluster" if @verbose
      stop if has_pid?
      start_cluster
      puts " * Elastic Search #{running_version} started" if @verbose
    end

    def stop
      if pid
        puts " * Will stop instance with pid #{pid}" if @verbose
        stop_cluster
      else
        puts " * No pidfile detected!. Won't stop" if @verbose
      end
    end

    def restart
      stop
      start
    end

    def status
      if version = running_version
        msg = "OK. Elastic Search cluster '#{cluster_health.cluster_name}' (v#{version}) is running on #{cluster_health.number_of_nodes} node(s) with status #{cluster_health.status}"
      else
        msg = "KO. No Elastic Search instance was found running on #{@client.uri}"
      end
      puts msg if @verbose
      msg
    end

    def has_pid?
      pid && !pid.empty?
    end

    def pid
      @pid ||= File.read(pidfile) if pidfile.exist?
    end

    def running_version
      begin
        JSON.parse(@client.get('/').body)["version"]["number"]
      rescue
        nil
      end
    end

    def wait_until_cluster_becomes_ready(max_wait = 10, step = 0.5)
      wait_for(max_wait, step) { cluster_ready? }
    end

    def wait_until_cluster_is_down(max_wait = 5, step = 0.3)
      wait_for(max_wait, step) { !cluster_ready? }
    end

    private

    def start_cluster
      line = Cocaine::CommandLine.new(@local_install.launcher.to_s, "-p :pidfile", pidfile: pidfile.to_s)
      line.run

      unless wait_until_cluster_becomes_ready
        raise "Cluster still not ready after #{max_wait} seconds!"
      end
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

    def cluster_health
      @cluster_health ||= OpenStruct.new(JSON.parse(@client.get('/_cluster/health').body))
    end

  end
end
