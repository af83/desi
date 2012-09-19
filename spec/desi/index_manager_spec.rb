# encoding: utf-8

require "spec_helper"
require "desi/index_manager"
require "json"

describe Desi::IndexManager do

  subject { described_class.new(http_client_factory: http_client_factory) }

  let(:http_client_factory) { double(new: http_client) }
  let(:http_client) { double('http_client') }

  def stub_request(method, path, payload)
    http_client.stub(method).with(path).and_return(
      mock("response", body: JSON.unparse(payload))
    )
  end

  def stub_indices(*names)
    stub_request(:get, '_status', {"indices" => Hash[Array(names).zip]})
  end

  before do
    stub_indices('foo', 'bar')
  end

  describe "#list" do
    context "with no specified pattern" do
      it "returns the names of all indices" do
        subject.list.should == %w[bar foo]
      end
    end

    context "with a pattern" do
      it "returns the matching indices" do
        subject.list('oo').should == %w[foo]
      end
    end

    context "when verbose is on" do
      let(:outputter) { double("outputter") }

      subject do
        described_class.new(
          http_client_factory: http_client_factory,
          outputter: outputter,
          verbose: true)
      end

      it "also outputs on STDOUT" do
        outputter.should_receive(:puts).at_least(:once)
        subject.list('oo')
      end
    end
  end

  describe "#delete!" do
    context "when the mandatory pattern is not specified" do
      it "raises an ArgumentError" do
        expect { subject.delete! }.to raise_error(ArgumentError)
      end
    end

    it "deletes all matching indices" do
      http_client.should_receive(:delete).with("foo")
      http_client.should_not_receive(:delete).with("bar")

      subject.delete!('f.*')
    end

    context "when verbose is on" do
      let(:outputter) { double("outputter") }

      subject do
        described_class.new(
          http_client_factory: http_client_factory,
          outputter: outputter,
          verbose: true)
      end

      it "also outputs on STDOUT" do
        http_client.stub(:delete)

        outputter.should_receive(:puts).at_least(:once)
        subject.delete!('f.*')
      end
    end
  end

  describe "#empty!" do
    context "when the mandatory pattern is not specified" do
      it "raises an ArgumentError" do
        expect { subject.empty! }.to raise_error(ArgumentError)
      end
    end

    it "deletes all matching indices" do
      http_client.should_receive(:delete).with("foo/_query?q=*")
      http_client.should_not_receive(:delete).with("bar")

      subject.empty!('f.*')
    end

    context "when verbose is on" do
      let(:outputter) { double("outputter") }

      subject do
        described_class.new(
          http_client_factory: http_client_factory,
          outputter: outputter,
          verbose: true)
      end

      it "also outputs on STDOUT" do
        http_client.stub(:delete)

        outputter.should_receive(:puts).at_least(:once)
        subject.empty!('f.*')
      end
    end
  end


end
