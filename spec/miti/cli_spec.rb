# frozen_string_literal: true

require_relative "../../lib/cli"

RSpec.describe Miti::CLI do
  describe "#difference" do
    it "raises Thor::Error for invalid input" do
      cli = described_class.new
      allow(Miti).to receive(:differentiate).and_raise(Miti::NepaliDate::FormatError, "invalid nepali date")

      expect { cli.difference("bad", "date") }.to raise_error(Thor::Error, "invalid nepali date")
    end
  end

  describe "#english_calendar" do
    it "raises Thor::Error when calendar generation fails" do
      cli = described_class.new
      allow(Miti::Calendar).to receive(:new).and_raise(Miti::ConversionUnavailableError, "out of supported range")

      expect { cli.english_calendar }.to raise_error(Thor::Error, "out of supported range")
    end
  end

  describe "#nepali_calendar" do
    it "raises Thor::Error when calendar generation fails" do
      cli = described_class.new
      allow(Miti::Calendar).to receive(:new).and_raise(Miti::ConversionUnavailableError, "out of supported range")

      expect { cli.nepali_calendar }.to raise_error(Thor::Error, "out of supported range")
    end
  end
end
