# frozen_string_literal: true

RSpec.describe Miti do
  describe ".to_bs" do
    it "converts AD string to NepaliDate" do
      result = described_class.to_bs("2022-10-12")
      expect(result).to be_a(Miti::NepaliDate)
      expect(result.to_s).to eq("2079-06-26")
    end

    it "converts Date object to NepaliDate" do
      result = described_class.to_bs(Date.new(2022, 10, 12))
      expect(result).to be_a(Miti::NepaliDate)
      expect(result.to_s).to eq("2079-06-26")
    end

    it "converts Time object to NepaliDate" do
      result = described_class.to_bs(Time.new(2022, 10, 12))
      expect(result).to be_a(Miti::NepaliDate)
      expect(result.to_s).to eq("2079-06-26")
    end

    it "raises ArgumentError for invalid date format" do
      expect { described_class.to_bs("not-a-date") }.to raise_error(ArgumentError)
    end

    it "raises ConversionUnavailableError for out-of-range year" do
      expect { described_class.to_bs("1900-01-01") }.to raise_error(Miti::ConversionUnavailableError)
    end
  end

  describe ".to_ad" do
    it "converts BS string to Date" do
      result = described_class.to_ad("2079-06-26")
      expect(result).to be_a(Date)
      expect(result).to eq(Date.new(2022, 10, 12))
    end

    it "converts NepaliDate object to Date" do
      nepali_date = Miti::NepaliDate.new(barsa: 2079, mahina: 6, gatey: 26)
      result = described_class.to_ad(nepali_date)
      expect(result).to be_a(Date)
      expect(result).to eq(Date.new(2022, 10, 12))
    end

    it "raises ConversionUnavailableError for out-of-range year" do
      expect { described_class.to_ad("2101-01-01") }.to raise_error(Miti::ConversionUnavailableError)
    end

    it "raises ArgumentError for invalid string format" do
      expect { described_class.to_ad("invalid") }.to raise_error(ArgumentError, "Invalid date format.")
    end
  end

  describe ".to_bs and .to_ad roundtrip" do
    it "produces consistent roundtrip results" do
      test_dates = %w[2022-01-01 2022-06-15 2023-12-31 2024-04-13 2025-09-01]
      test_dates.each do |ad_date|
        bs = described_class.to_bs(ad_date)
        ad_back = described_class.to_ad(bs.to_s)
        expect(ad_back.to_s).to eq(Date.parse(ad_date).to_s)
      end
    end
  end
end
