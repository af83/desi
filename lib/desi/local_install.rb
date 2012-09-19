# encoding: utf-8

require "pathname"

module Desi
  class LocalInstall
    DEFAULT_DIR = '~/elasticsearch'

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
        @version ||= /^elasticsearch\-(?<version>.*)$/.match(name.to_s)[:version]
      end

      def to_s
        current_mark = current? ? '*' : '-'

        " #{current_mark} #{name} (#{@dirname})"
      end

      def <=>(other)
        name <=> other.name
      end

      private

      def current_symlink
        @current_symlink ||= Pathname(@workdir).join('current')
      end

      def current_symlink?
        current_symlink.exist?
      end
    end

    def initialize(workdir = nil)
      @workdir = Pathname(File.expand_path(workdir || DEFAULT_DIR))
    end

    def exists?
      @workdir.exist?
    end

    def current_dir
      @workdir.join('current')
    end

    def create!
      FileUtils.mkdir_p @workdir
    end

    def releases
      Release.all_in(@workdir)
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

    def launcher
      current_dir.join('bin', 'elasticsearch')
    end
  end
end
