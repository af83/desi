# encoding: utf-8

module Desi
  class LocalInstall
    DEFAULT_DIR = '~/elasticsearch'

    def initialize(workdir = DEFAULT_DIR)
      @workdir = Pathname(File.expand_path(workdir))
    end

    def exists?
      @workdir.exist?
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
  end
end
