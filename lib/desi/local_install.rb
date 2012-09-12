# encoding: utf-8

module Desi
  class LocalInstall
    DEFAULT_DIR = '~/elasticsearch'

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

    def versions
      Dir[@workdir.join('*')].select {|subdir| File.directory?(subdir) && File.basename(subdir) =~ /^elasticsearch\-\d+\.\d+\.\d+/ }
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

  end
end
