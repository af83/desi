# encoding: utf-8

require_relative "local_install/release"

module Desi
  class LocalInstall

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
      @current_dir ||= @workdir.join('current')
    end

    def update_current_to(release_dir)
      current_dir_must_be_nil_or_symlink!

      puts " * Updating #{current_dir} symlink" if @verbose
      FileUtils.remove(current_dir) if current_dir.exist?
      FileUtils.ln_sf(release_dir, current_dir)
      self
    end

    def add_data_symlink(release_dir)
      current_dir_must_be_nil_or_symlink!
      symlink = current_dir.join('data')
      FileUtils.mkdir_p data_dir
      puts " * Updating data dir symlink (#{symlink} -> #{data_dir})" if @verbose
      FileUtils.ln_sf(data_dir, symlink)
      self
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

    def data_dir
      @data_dir ||= @workdir.join('data')
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
