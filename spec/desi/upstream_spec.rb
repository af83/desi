# encoding: utf-8
require "spec_helper"
require "desi/upstream"

describe Desi::Upstream::Release do
  context "sort" do
    let(:v1) { Desi::Upstream::Release.new("v1.0.0", "") }
    let(:v09) { Desi::Upstream::Release.new("v0.90.10", "") }

    it "sort the v1.0.0 before v0.90.10" do
      expect([v09, v1].sort).to eql([v1, v09])
    end
  end
end
