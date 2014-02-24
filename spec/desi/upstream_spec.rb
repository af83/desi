# encoding: utf-8
require "spec_helper"
require "desi/upstream"

describe Desi::Upstream::Release do
  context "sort" do
    let(:v1) { Desi::Upstream::Release.new("v1.0.0", "") }
    let(:v09) { Desi::Upstream::Release.new("v0.90.10", "") }

    it "sorts the v1.0.0 before v0.90.10" do
      expect([v09, v1].sort).to eql([v1, v09])
    end

    it "sorts 1.0.0.RC2 before 1.0.0" do
      expect([
        Desi::Upstream::Release.new("v1.0.0.Beta1", ""),
        Desi::Upstream::Release.new("v1.0.0.RC2", ""),
        Desi::Upstream::Release.new("v1.0.0", ""),
        Desi::Upstream::Release.new("v1.0.0.Beta2", ""),
        Desi::Upstream::Release.new("v1.0.0.RC1", ""),
      ].sort).to eql([
        Desi::Upstream::Release.new("v1.0.0", ""),
        Desi::Upstream::Release.new("v1.0.0.RC2", ""),
        Desi::Upstream::Release.new("v1.0.0.RC1", ""),
        Desi::Upstream::Release.new("v1.0.0.Beta2", ""),
        Desi::Upstream::Release.new("v1.0.0.Beta1", "")
        ])
    end
  end
end
