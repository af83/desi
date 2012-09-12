# encoding: utf-8

require "fileutils"
require "cocaine"

module Desi
  class Installer

    def initialize(archive, destination_dir = nil)
      @archive = archive.to_s
      @local_install = Desi::LocalInstall.new(destination_dir)
    end

    def install!
      extract! unless extracted?
      install_config_file
      update_symlink!
    end

    def extracted?
      !!@extracted
    end

    def install_config_file
      unless original_config_backup.exist?
        puts " * Installing custom config file"
        FileUtils.mv config_file, original_config_backup
        FileUtils.cp our_config_file, config_file
      end
    end


    def update_symlink!
      unless @local_install.current_dir.symlink?
        raise "Mmmm!! #{@local_install.current_dir} is not a symlink!"
      end

      puts " * Updating #{@local_install.current_dir} symlink"
      FileUtils.remove(@local_install.current_dir)
      FileUtils.ln_sf(release_dir, @local_install.current_dir)
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
      line = Cocaine::CommandLine.new("tar", "--keep-newer-files -C :extract_dir -zxf :archive", extract_dir: @local_install.to_s, archive: @archive)
      begin
        line.run
      rescue Cocaine::CommandNotFoundError => e
        warn "The tar command must be available for this to work! #{e}"
        exit 1
      else
        @extracted = true
      end
    end

    def release_dir
      @release_dir ||= Pathname(@local_install).join(File.basename(@archive, '.tar.gz'))
    end

  end
end
