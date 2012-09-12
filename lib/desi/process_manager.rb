# encoding: utf-8

require "json"
require "cocaine"
require "ostruct"

module Desi
  class ProcessManager

    def initialize(opts = {})
      @verbose = opts[:verbose]
      @local_install = LocalInstall.new
      @client = Desi::HttpClient.new('http://localhost:9200/')
    end

    def start
      puts " * Starting cluster" if @verbose
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
        msg = "OK. Elastic Search cluster '#{cluster.cluster_name}' (v#{version}) is running on #{cluster.number_of_nodes} node(s) with status #{cluster.status}"
      else
        msg = "KO. No Elastic Search instance was found running on #{@client.uri}"
      end
      puts msg if @verbose
      msg
    end

    private

    def start_cluster
      line = Cocaine::CommandLine.new(@local_install.launcher.to_s, "-p :pidfile", pidfile: pidfile.to_s)
      line.run

      unless (wait_for() { cluster_ready? })
        raise "Cluster still not ready after #{max_wait} seconds!"
      end
    end

    def stop_cluster
      kill!

      unless (wait_for() { !cluster_ready? })
        raise "Strange. Cluster seems still up after #{max_wait} seconds!"
      end
    end

    def kill!
      Process.kill("HUP", Integer(pid)) if has_pid?
    end

    def has_pid?
      pid && !pid.empty?
    end

    def pid
      @pid ||= File.read(pidfile) if pidfile.exist?
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

    def running_version
      begin
        JSON.parse(@client.get('/').body)["version"]["number"]
      rescue
        nil
      end
    end

    def cluster
      @cluster ||= OpenStruct.new(JSON.parse(@client.get('/_cluster/health').body))
    end

  end
end
