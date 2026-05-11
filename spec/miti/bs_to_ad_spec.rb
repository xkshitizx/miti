# frozen_string_literal: true

RSpec.describe Miti::BsToAd do
  let!(:nepali_dates) do
    {
      Miti::NepaliDate.new(barsa: 2078, mahina: 9, gatey: 17) => Date.new(2022, 1, 1),
      Miti::NepaliDate.new(barsa: 2079, mahina: 5, gatey: 16) => Date.new(2022, 9, 1),
      Miti::NepaliDate.new(barsa: 2079, mahina: 9, gatey: 16) => Date.new(2022, 12, 31),
      Miti::NepaliDate.new(barsa: 2079, mahina: 9, gatey: 30) => Date.new(2023, 1, 14),
      Miti::NepaliDate.new(barsa: 2079, mahina: 2, gatey: 18) => Date.new(2022, 6, 1),
      Miti::NepaliDate.new(barsa: 2081, mahina: 1, gatey: 1) => Date.new(2024, 4, 13),
      Miti::NepaliDate.new(barsa: 2081, mahina: 9, gatey: 17) => Date.new(2025, 1, 1),
    }
  end

  it "always returns instance of Date" do
    nepali_dates.each_key do |nepali_date|
      expect(described_class.new(nepali_date).convert.class).to eq(Date)
    end
  end

  it "returns equivalent AD for BS" do
    nepali_dates.each_key do |nepali_date|
      english_date = described_class.new(nepali_date).convert
      expect(english_date).to eq(nepali_dates[nepali_date])
    end
  end
end
