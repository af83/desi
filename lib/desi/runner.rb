# encoding: utf-8

require 'boson/runner'

module Desi
  class Runner < Boson::Runner

    desc "List locally installed Elastic Search versions"
    def list
      puts "Local ES installs:"
      Desi::LocalInstall.new.versions.each do |v|
        puts "* #{v}"
      end
    end

    desc "List all available ElasticSearch versions"
    def list_all
      Desi::Upstream.new.releases.each do |v|
        puts " * #{v.name} -- #{v.description} (#{v.release_date})"
      end
    end

    desc "Install ES (to latest stable version by default)"
    def install(version_or_full_name = nil, options = {})
      release = if version_or_full_name
                  Desi::Upstream.new.find_release(version_or_full_name)
                else
                  puts " * No release specified, will fetch latest."
                  Desi::Upstream.new.latest_release
                end

      puts " * fetching release #{release}"
      package = Desi::Downloader.new.download!(release)

      puts " * #{release} installed" if Desi::Installer.new(package).install!
    end

    desc "Start or restart Elastic Search"
    def start
      Desi::ProcessManager.new.start
    end

    desc "Stop Elastic Search"
    def stop
      Desi::ProcessManager.new.stop
    end

    desc "Show current status"
    def status
      Desi::ProcessManager.new.status
    end

    # desc "Upgrade to latest ElasticSearch version"
    # def upgrade
    # end

    # desc "Switch currently active ES version to VERSION"
    # option :version, type: :string
    # def switch
    # end

  end
end
