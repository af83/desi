# encoding: utf-8

require 'boson/runner'
require "pp"

module Desi
  class Runner < Boson::Runner

    desc "List locally installed Elastic Search versions"
    def list
      require 'desi/local_install'
      puts "Local ES installs:"
      Desi::LocalInstall.new.versions.each do |v|
        puts "* #{v}"
      end
    end

    desc "List all available ElasticSearch versions"
    def list_all
      require 'desi/registry'
      Desi::Registry.new.releases.each do |v|
        puts " * #{v.name} -- #{v.description} (#{v.release_date})"
      end
    end

    # option :version, :type => :string #, desc: "Version (latest stable by default)"
    desc "Install ES (to latest stable version by default)"
    def install
      puts " * fetching latest version"
      require 'desi/registry'
      require 'desi/downloader'
      release = Desi::Registry.new.latest_release
      Desi::Downloader.new.download!(release)
    end

    desc "Upgrade to latest ElasticSearch version"
    def upgrade
    end

    desc "Start or restart Elastic Search"
    def start
    end

    desc "Stop Elastic Search"
    def stop
    end

    desc "Switch currently active ES version to VERSION"
    option :version, type: :string
    def switch
    end

  end
end
