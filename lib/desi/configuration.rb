# encoding: utf-8

require "singleton"
require "yaml"
require "pathname"

module Desi
  class Configuration

    DEFAULTS = {
      directory:  "~/elasticsearch",
      server:     "localhost:9200"
    }.freeze

    class Settings
      include Singleton

      attr_accessor :server
      attr_reader :directory

      def directory=(dir)
        @directory = Pathname(File.expand_path(dir))
      end
    end

    # @api private
    def load_configuration!
      config = stringify_keys(DEFAULTS).merge(config_files_data)

      settings.public_methods(false).select {|m| m.to_s =~ /=$/ }.each do |setter|
        attr_name = setter.to_s.tr('=', '')

        if config.has_key?(attr_name)
          settings.send(setter, config[attr_name])
        end
      end

      self
    end

    # @api private
    def config_files
      [system_wide_config_file, user_config_file]
    end

    # @api private
    def system_wide_config_file
      "/etc/desi.yml".freeze
    end

    # @api private
    def user_config_file
      dir = environment["XDG_CONFIG_HOME"]

      if dir
        File.join(dir, "desi", "config.yml")
      else
        "~/.desi.yml"
      end
    end

    # @api private
    attr_writer :environment

    private

    def settings
      Settings.instance
    end

    def environment
      @environment || ENV
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
        stringify_keys data
      else
        warn "Configuration file #{filename} contains malformed data and will be ignored"
        {}
      end
    end

    def stringify_keys(hash)
      new = {}
      hash.each_key do |key|
        new[key.to_s] = hash[key]
      end
    end

    new.load_configuration!
  end # Configuration

  module_function


  # Change configuration settings
  #
  # @example
  #
  # Desi.configure do |c|
  #   c.directory = "~/es"
  #   c.server = "127.0.0.53:9200"
  # end
  #
  # @return [Desi::Configuration] the configuration
  def configure(&block)
    yield configuration
    configuration
  end

  def configuration
    Configuration::Settings.instance
  end

end
