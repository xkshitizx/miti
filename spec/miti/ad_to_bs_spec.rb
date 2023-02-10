# frozen_string_literal: true

RSpec.describe Miti::AdToBs do
  let!(:english_dates) do
    {
      Date.new(2022, 1, 1) => "2078-09-17",
      Date.new(2022, 9, 1) => "2079-05-16",
      Date.new(2022, 12, 31) => "2079-09-16",
      Date.new(2023, 1, 14) => "2079-09-30",
      Date.new(2022, 6, 1) => "2079-02-18",
      Date.new(2024, 4, 13) => "2081-01-01",
      Date.new(1995, 2, 15) => "2051-11-03",
      Date.new(2023, 2, 15) => "2079-11-03",
      Date.new(2025, 2, 15) => "2081-11-03",
      Date.new(2025, 1, 1) => "2081-09-17",
      Date.new(2025, 9, 1) => "2082-05-16",
      Date.new(2025, 12, 31) => "2082-09-16",
      Date.new(2025, 1, 14) => "2081-10-01",
      Date.new(2025, 6, 1) => "2082-02-19",
      Date.new(2025, 4, 13) => "2081-12-30",
      Date.new(2025, 2, 15) => "2081-11-03"
    }
  end

  it "always returns instance of Miti::NepaliDate" do
    english_dates.each_key do |english_date|
      expect(described_class.new(english_date).convert.class).to eq(Miti::NepaliDate)
    end
  end

  it "returns equivalent AD for BS" do
    english_dates.each_key do |english_date|
      nepali_date = described_class.new(english_date).convert

      expect(nepali_date.to_s).to eq(english_dates[english_date])
    end
  end
end
