# encoding: utf-8

require "fileutils"
require "desi/cocaine"

module Desi
  class Installer

    def initialize(archive, opts = {})
      @verbose = opts[:verbose]
      @archive = archive.to_s
      @local_install = Desi::LocalInstall.new(opts[:destination_dir], verbose: @verbose)
    end

    def install!
      extract! unless extracted?
      install_config_file
      update_symlinks!
      remove_archive!
    end

    def extracted?
      !!@extracted
    end

    def install_config_file
      unless original_config_backup.exist?
        puts " * Installing custom config file" if @verbose
        FileUtils.mv config_file, original_config_backup
        FileUtils.cp our_config_file, config_file
      end
    end


    def update_symlinks!
      @local_install.
        update_current_to(release_dir).
        add_data_symlink(release_dir)
    end

    def config_file
      release_dir.join('config', 'elasticsearch.yml')
    end

    def original_config_backup
      release_dir.join('config', 'elasticsearch.yml.dist')
    end

    def our_config_file
      File.expand_path('../../../config/elasticsearch.yml', __FILE__)
    end

    private

    def extract!
      line = Cocaine::CommandLine.new("tar", "--keep-newer-files -C :extract_dir -zxf :archive")
      begin
        line.run(extract_dir: @local_install.to_s, archive: @archive)
      rescue Cocaine::CommandNotFoundError => e
        warn "The tar command must be available for this to work! #{e}"
        exit 1
      else
        @extracted = true
      end
    end

    def remove_archive!
      FileUtils.rm @archive
    end

    def release_dir
      @release_dir ||= Pathname(@local_install).join(File.basename(@archive, '.tar.gz'))
    end

  end
end
