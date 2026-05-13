# frozen_string_literal: true

require_relative "../../lib/calendar"

RSpec.describe Miti::Calendar do
  before do
    allow(Date).to receive(:today).and_return(Date.new(2026, 5, 12))
  end

  describe "#english_calendar" do
    it "returns calendar title and week headers" do
      output = described_class.new.english_calendar

      expect(output.lines[0].strip).to eq("Calendar for May 2026")
      expect(output).to include("Sun Mon Tue Wed Thu Fri Sat")
      expect(output).to include("                      1   2")
    end

    it "highlights today through the provided shell" do
      shell = instance_double("Thor::Shell::Color")
      allow(shell).to receive(:set_color).and_return("<green-bold-12>")

      output = described_class.new(shell: shell).english_calendar

      expect(shell).to have_received(:set_color).with(" 12", :green, true)
      expect(output).to include("<green-bold-12>")
    end
  end

  describe "#nepali_calendar" do
    it "uses shared month names from NepaliDate constants" do
      months = Miti::NepaliDate::MONTHS_IN_ENGLISH.dup
      months[0] = "TestMonth"
      stub_const("Miti::NepaliDate::MONTHS_IN_ENGLISH", months)

      output = described_class.new.nepali_calendar

      expect(output.lines[0].strip).to eq("Calendar for TestMonth 2083")
    end
  end
end
