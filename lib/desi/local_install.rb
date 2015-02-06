# encoding: utf-8

require "pathname"
require "semantic"

module Desi
  class LocalInstall

    class Release
      def self.all_in(workdir)
        Dir[workdir.join('*')].
          select {|subdir| File.directory?(subdir) && File.basename(subdir) =~ /^elasticsearch\-\d+\.\d+\.\d+/ }.
          map {|dirname| new(dirname, workdir) }
      end

      def initialize(dirname, workdir)
        @dirname = Pathname.new(dirname)
        @workdir = workdir
      end

      def name
        @name ||= File.basename(@dirname)
      end

      def current?
        current_symlink? && current_symlink.realpath == @dirname
      end

      def version
        @version ||= Semantic::Version.new(version_number)
      end

      def to_s
        current_mark = current? ? '*' : '-'

        " #{current_mark} #{name} (#{@dirname})"
      end

      def ==(other)
        other.version.to_s == version.to_s
      end

      def <=>(other)
        name <=> other.name
      end

      def pre_one_zero?
        @pre_one_zero ||= (version < Semantic::Version.new("1.0.0-alpha"))
      end

      private

      def current_symlink
        @current_symlink ||= Pathname(@workdir).join('current')
      end

      def current_symlink?
        current_symlink.exist?
      end

      # Ugly hack to get around elasticsearch's flakey semver naming
      # (e.g. `1.4.0.Beta1` instead of `1.4.0-beta1`)
      def version_number
        /^elasticsearch\-(?<version>.*)$/.match(name.to_s)[:version].
          sub(/\.(alpha|beta)/i, '-\1')
      end
    end # Release

    def self.current_release_is_pre_one_zero?
      current = new.current_release
      current && current.pre_one_zero?
    end

    def initialize(workdir = nil, opts = {})
      @verbose = opts[:verbose]
      @workdir = Pathname(File.expand_path(workdir || Desi.configuration.directory))
      create!
    end

    def exists?
      @workdir.exist?
    end

    def current_dir
      @workdir.join('current')
    end

    def update_current_to(release_dir)
      current_dir_must_be_nil_or_symlink!

      puts " * Updating #{current_dir} symlink" if @verbose
      FileUtils.remove(current_dir) if current_dir.exist?
      FileUtils.ln_sf(release_dir, current_dir)
    end

    def create!
      FileUtils.mkdir_p @workdir
    end

    def releases
      Release.all_in(@workdir)
    end

    def current_release
      releases.find {|r| r.current? }
    end

    def to_path
      @workdir.to_s
    end

    def to_s
      to_path
    end

    def pidfile
      @workdir.join('elasticsearch.pid')
    end

    def logfile
      current_dir.join('logs', 'elasticsearch.log')
    end

    def launcher
      current_dir.join('bin', 'elasticsearch')
    end

    private

    def current_dir_must_be_nil_or_symlink!
      if current_dir.exist? && ! current_dir.symlink?
        raise "Mmmm!! #{current_dir} is not a symlink!"
      end
    end
  end
end
