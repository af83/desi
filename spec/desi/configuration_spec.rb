# encoding: utf-8

require "spec_helper"
require "desi/configuration"

describe Desi::Configuration do
  subject { Desi.configuration }

  its(:system_wide_config_file) { eq "/etc/desi.yml" }

  describe "#user_config_file" do
    context "when XDG_CONFIG_HOME is not set" do
      it "defaults to ~/.desi.yml" do
        expect(subject.user_config_file).to eq("~/.desi.yml")
      end
    end

    context "when XDG_CONFIG_HOME is set" do
      before do
        subject.environment = {"XDG_CONFIG_HOME" => "/tmp"}
      end

      it "is set to $XDG_CONFIG_HOME/desi/config.yml" do
        expect(subject.user_config_file).to eq("/tmp/desi/config.yml")
      end
    end
  end

end
