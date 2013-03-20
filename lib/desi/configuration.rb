# encoding: utf-8

require "singleton"
require "yaml"
require "pathname"

module Desi

  class Configuration
    include Singleton

    attr_reader :directory

    def directory=(dir)
      @directory = Pathname(File.expand_path(dir))
    end

    def load_configuration!
      config = defaults.merge(config_files_data)

      public_methods(false).select {|m| m.to_s =~ /=$/ }.each do |setter|
        attr_name = setter.to_s.tr('=', '')

        if config.has_key?(attr_name)
          send(setter, config[attr_name])
        end
      end

      self
    end

    private

    def config_files
      %w[/etc/desi.yml ~/.desi.yml]
    end

    def config_files_data
      config_files.each_with_object({}) do |filename, hash|
        hash.merge! config_file_data(filename)
      end
    end

    def config_file_data(filename)
      file = File.expand_path(filename)
      return {} unless File.exists?(file)

      data = YAML.load_file(file)

      if data.is_a? Hash
        data
      else
        warn "Configuration file #{filename} contains malformed data and will be ignored"
        {}
      end
    end

    def defaults
      {'directory' => "~/elasticsearch"}
    end

    instance.load_configuration!
  end # Configuration

  module_function


  # Change configuration settings
  #
  # @example
  #
  # Desi.configure do |c|
  #   c.directory = "~/es"
  # end
  #
  # @return [Desi::Configuration] the configuration
  def configure(&block)
    yield configuration
    configuration
  end

  def configuration
    Configuration.instance
  end

end
