# encoding: utf-8

require 'boson/runner'

module Desi
  class Runner < Boson::Runner

    def self.verbosity_option
      option :verbose, type: :boolean, desc: "Display information messages", default: STDOUT.tty?
      option :quiet,   type: :boolean, desc: "Do not output anything", default: !STDOUT.tty?
    end

    desc "List locally installed Elastic Search versions"
    verbosity_option
    def list(options = {})
      puts "Local ES installs:" unless quiet?(options)
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
    verbosity_option
    def install(version_or_full_name = nil, options = {})
      release = if version_or_full_name
                  Desi::Upstream.new.find_release(version_or_full_name)
                else
                  puts " * No release specified, will fetch latest." unless quiet?(options)
                  Desi::Upstream.new.latest_release
                end

      puts " * fetching release #{release}" unless quiet?(options)
      package = Desi::Downloader.new(verbose: !quiet?(options)).download!(release)

      puts " * #{release} installed" if Desi::Installer.new(package).install! && !quiet?(options)
    end

    desc "Start or restart Elastic Search"
    verbosity_option
    def start(options = {})
      Desi::ProcessManager.new.start(verbose: !quiet?(options))
    end

    desc "Stop Elastic Search"
    verbosity_option
    def stop(options = {})
      Desi::ProcessManager.new.stop(verbose: !quiet?(options))
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

    private

    def quiet?(opts = {})
      opts[:quiet] || !opts[:verbose]
    end

  end
end
