# encoding: utf-8

require "json"
require "cocaine"

module Desi
  class ProcessManager

    def initialize
      @local_install = LocalInstall.new
      @client = Desi::HttpClient.new('http://localhost:9200/')
    end

    def start
      puts " * Starting cluster"
      stop if started?
      start_cluster
    end

    def stop
      if pid
        puts " * Will stop instance with pid #{pid}"
        stop_cluster
      else
        puts " * No pidfile detected!. Won't stop"
      end
    end

    def restart
      stop
      start
    end

    def started?
      pidfile.exist?
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
      Process.kill("HUP", Integer(pid)) unless !pid || pid.empty?
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

  end
end
