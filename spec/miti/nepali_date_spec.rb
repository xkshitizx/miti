# frozen_string_literal: true

RSpec.describe Miti::NepaliDate do
  subject(:nepali_date) { described_class.new(barsa: 2079, mahina: 6, gatey: 26) }

  describe "#to_s" do
    it "returns yyyy-mm-dd by default" do
      expect(nepali_date.to_s).to eq("2079-06-26")
    end

    it "accepts custom separator" do
      expect(nepali_date.to_s(separator: "/")).to eq("2079/06/26")
    end

    it "accepts space separator" do
      expect(nepali_date.to_s(separator: " ")).to eq("2079 06 26")
    end

    it "raises on invalid separator" do
      expect { nepali_date.to_s(separator: ".") }.to raise_error(described_class::InvalidSeparatorError)
    end
  end

  describe "#descriptive" do
    it "returns english description by default" do
      expect(nepali_date.descriptive).to match(/Asoj 26, 2079 \w+/)
    end

    it "returns nepali description when flag is set" do
      expect(nepali_date.descriptive(nepali: true)).to match(/.+ 26, 2079 .+\(.+\)/)
    end
  end

  describe "#tarik" do
    it "returns equivalent english date" do
      expect(nepali_date.tarik).to eq(Date.new(2022, 10, 12))
    end
  end

  describe "#bar" do
    it "returns weekday index" do
      expect(nepali_date.bar).to be_an(Integer)
      expect(nepali_date.bar).to be_between(0, 6)
    end
  end

  describe "#to_h" do
    it "returns hash with all attributes" do
      hash = nepali_date.to_h
      expect(hash).to include(barsa: 2079, mahina: 6, gatey: 26, bar: an_instance_of(Integer))
      expect(hash[:tarik]).to be_a(Date)
    end
  end

  describe "#yday" do
    it "returns day of year" do
      expect(nepali_date.yday).to be_an(Integer)
      expect(nepali_date.yday).to be_between(1, 366)
    end
  end

  describe ".today" do
    it "returns a NepaliDate for today" do
      expect(described_class.today).to be_a(described_class)
    end
  end

  describe ".parse" do
    it "parses yyyy-mm-dd string" do
      parsed = described_class.parse("2079-06-26")
      expect(parsed.barsa).to eq(2079)
      expect(parsed.mahina).to eq(6)
      expect(parsed.gatey).to eq(26)
    end

    it "parses yyyy/mm/dd string" do
      parsed = described_class.parse("2079/06/26")
      expect(parsed.barsa).to eq(2079)
      expect(parsed.mahina).to eq(6)
      expect(parsed.gatey).to eq(26)
    end

    it "raises on invalid date format" do
      expect { described_class.parse("invalid") }.to raise_error(described_class::FormatError)
    end

    it "rejects unsupported separators" do
      expect { described_class.parse("2079.06.26") }.to raise_error(described_class::FormatError)
      expect { described_class.parse("2079,06,26") }.to raise_error(described_class::FormatError)
      expect { described_class.parse("2079 06 26") }.to raise_error(described_class::FormatError)
    end

    it "raises on invalid mahina" do
      expect { described_class.parse("2079-13-01") }
        .to raise_error(described_class::DateRangeError, "Month should range from 1 to 12")
    end

    it "raises on gatey exceeding max for month" do
      expect { described_class.parse("2079-06-32") }
        .to raise_error(described_class::DateRangeError, /exceeds the max available gatey/)
    end
  end
end
