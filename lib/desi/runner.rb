# encoding: utf-8

require 'boson/runner'

module Desi
  class Runner < Boson::Runner

    def self.verbosity_option
      option :verbose, type: :boolean, desc: "Display information messages", default: STDOUT.tty?
      option :quiet,   type: :boolean, desc: "Do not output anything", default: !STDOUT.tty?
    end

    desc "List locally installed Elastic Search releases"
    verbosity_option
    def list(options = {})
      puts "Local ES installs (current one is tagged with '*'):" unless quiet?(options)
      Desi::LocalInstall.new.releases.sort.reverse.each do |v|
        puts v
      end
    end

    desc "List latest ElasticSearch releases (latest 5 by default)"
    verbosity_option
    option :limit, type: :numeric, desc: "Number of releases to show (0 for all)", default: 5
    def releases(options = {})
      limit = options[:limit]
      releases = Desi::Upstream.new.releases.each_with_index.
        take_while {|rel, i| i < limit || limit == 0 }.map(&:first)

      if quiet?(options)
        releases
      else
        puts "Here are #{limit == 0 ? 'all the' : "the #{limit} latest"} releases"
        releases.each {|rel| puts " - #{rel.name} (#{rel.release_date})" }
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

    desc "Start Elastic Search (do nothing if already active)"
    verbosity_option
    def start(options = {})
      Desi::ProcessManager.new(verbose: !quiet?(options)).start
    end

    desc "Start or restart Elastic Search (restart if already active)"
    verbosity_option
    def restart(options = {})
      Desi::ProcessManager.new(verbose: !quiet?(options)).restart
    end

    desc "Stop Elastic Search"
    verbosity_option
    def stop(options = {})
      Desi::ProcessManager.new(verbose: !quiet?(options)).stop
    end

    desc "Show current status"
    verbosity_option
    option "--host", type: :string, desc: "Elastic Search cluster URL", default: '127.0.0.1:9200'
    def status(options = {})
      Desi::ProcessManager.new(verbose: !quiet?(options), host: options[:host]).status
    end

    desc "List indices"
    verbosity_option
    option "--host", type: :string, desc: "Elastic Search cluster URL", default: '127.0.0.1:9200'
    option "--delete", type: :boolean, desc: "Delete the specified indices (You've been warned!)", default: false
    option "--empty", type: :boolean, desc:  "Delete all documents from the specified indices", default: false
    def indices(pattern = nil, options = {})
      index_manager = Desi::IndexManager.new(verbose: !quiet?(options), host: options[:host])

      if options[:delete]
        index_manager.delete!(pattern)
      elsif options[:empty]
        index_manager.empty!(pattern)
      else
        index_manager.list(pattern)
      end
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
