# encoding: utf-8

require 'boson/runner'
require "desi/configuration"

module Desi
  class Runner < Boson::Runner

    def self.verbosity_option
      option :verbose, type: :boolean, desc: "Display information messages", default: STDOUT.tty?
      option :quiet,   type: :boolean, desc: "Do not output anything", default: !STDOUT.tty?
    end

    def self.start_options
      option :foreground, type: :boolean, desc: "Run ES in the foreground", default: false
      option :tail, type: :boolean, desc: "Run tail after (re)starting", default: false
    end

    desc "List locally installed Elastic Search releases"
    verbosity_option
    def list(options = {})
      set_verbosity!(options)
      puts "Local ES installs in #{Desi.configuration.directory} (current one is tagged with '*'):" if options[:verbose]
      Desi::LocalInstall.new.releases.sort.reverse.each do |v|
        puts v
      end
    end

    desc "List latest ElasticSearch releases (latest 5 by default)"
    verbosity_option
    option :limit, type: :numeric, desc: "Number of releases to show (0 for all)", default: 5
    def releases(options = {})
      set_verbosity!(options)
      limit = options[:limit]
      releases = Desi::Upstream.new.releases.each_with_index.
        take_while {|rel, i| i < limit || limit == 0 }.map(&:first)

      if options[:verbose]
        puts "Here are #{limit == 0 ? 'all the' : "the #{limit} latest"} releases"
        releases.each {|rel| puts " - #{rel.name}" }
      else
        releases
      end
    end

    desc "Install ES (to latest stable version by default)"
    verbosity_option
    def install(version_or_full_name = nil, options = {})
      set_verbosity!(options)
      release = if version_or_full_name
                  Desi::Upstream.new.find_release(version_or_full_name)
                else
                  puts " * No release specified, will fetch latest." if options[:verbose]
                  Desi::Upstream.new.latest_release
                end

      puts " * fetching release #{release}" if options[:verbose]
      package = Desi::Downloader.new(options).download!(release)

      puts " * #{release} installed" if Desi::Installer.new(package).install! && options[:verbose]
    end

    desc "Start Elastic Search (do nothing if already active)"
    verbosity_option
    start_options
    def start(options = {})
      set_verbosity!(options)
      Desi::ProcessManager.new(options).start
    end

    desc "Start or restart Elastic Search (restart if already active)"
    verbosity_option
    start_options
    def restart(options = {})
      set_verbosity!(options)
      Desi::ProcessManager.new(options).restart
    end

    desc "Stop Elastic Search"
    verbosity_option
    def stop(options = {})
      set_verbosity!(options)
      Desi::ProcessManager.new(options).stop
    end

    desc "Show current status"
    verbosity_option
    option "--host", type: :string, desc: "Elastic Search cluster URL", default: Desi.configuration.server
    def status(options = {})
      set_verbosity!(options)
      Desi::ProcessManager.new(options).status
    end

    desc "List indices"
    verbosity_option
    option "--host", type: :string, desc: "Elastic Search cluster URL", default: Desi.configuration.server
    option "--delete", type: :boolean, desc: "Delete the specified indices (You've been warned!)", default: false
    option "--empty", type: :boolean, desc:  "Delete all documents from the specified indices", default: false
    def indices(pattern = nil, options = {})
      set_verbosity!(options)
      index_manager = Desi::IndexManager.new(options)

      if options[:delete]
        index_manager.delete!(pattern)
      elsif options[:empty]
        index_manager.empty!(pattern)
      else
        index_manager.list(pattern)
      end

    rescue Errno::ECONNREFUSED
      warn "Server #{options[:host]} appears to be unavailable!"
      exit 1
    end

    desc "Show tail output from Elastic Search's log file"
    def tail
      Desi::ProcessManager.new.show_tail
    end

    private

    def set_verbosity!(opts)
      opts[:verbose] ||= opts.delete(:quiet)
    end

  end
end
