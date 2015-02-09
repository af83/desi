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

      def with_version?(other_version)
        version == Semantic::Version.new(other_version)
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

      def to_path
        @dirname.to_path
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

  end
end
