# frozen_string_literal: true

RSpec.describe Miti::AdToBs do
  let(:date) { Date.new(2022, 1, 1) } # english new year
  let(:date1) { Date.new(2022, 9, 1) } # more than 365
  let(:date2) { Date.new(2022, 12, 31) } # last english day of month
  let(:date3) { Date.new(2023, 1, 14) } # last english day of month
  let(:date4) { Date.new(2022, 6, 1) } # less than 365
  let(:date5) { Date.new(2024, 4, 13) } # nepali new year/leap year
  let(:date7) { Date.new(1995, 2, 15) }
  let(:date8) { Date.new(2023, 2, 15) } # birthday
  # leap year next year
  let(:date6) { Date.new(2025, 2, 15) } # birthday
  let(:date10) { Date.new(2025, 1, 1) } # english new year
  let(:date11) { Date.new(2025, 9, 1) } # more than 365
  let(:date12) { Date.new(2025, 12, 31) } # last english day of month
  let(:date13) { Date.new(2025, 1, 14) } # last english day of month
  let(:date14) { Date.new(2025, 6, 1) } # less than 365
  let(:date15) { Date.new(2025, 4, 13) } # nepali new year/leap year
  let(:date17) { Date.new(2025, 2, 15) }

  subject { described_class.new(date).convert(to_h: true) }

  it "returns equivalent AD for BS" do
    expect(described_class.new(date).convert(to_h: true)).to eq({ barsa: 2078, mahina: 9, gatey: 17 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date1).convert(to_h: true)).to eq({ barsa: 2079, mahina: 5, gatey: 16 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date2).convert(to_h: true)).to eq({ barsa: 2079, mahina: 9, gatey: 16 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date3).convert(to_h: true)).to eq({ barsa: 2079, mahina: 9, gatey: 30 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date4).convert(to_h: true)).to eq({ barsa: 2079, mahina: 2, gatey: 18 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date5).convert(to_h: true)).to eq({ barsa: 2081, mahina: 1, gatey: 1 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date6).convert(to_h: true)).to eq({ barsa: 2081, mahina: 11, gatey: 3 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date7).convert(to_h: true)).to eq({ barsa: 2051, mahina: 11, gatey: 3 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date8).convert(to_h: true)).to eq({ barsa: 2079, mahina: 11, gatey: 3 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date10).convert(to_h: true)).to eq({ barsa: 2081, mahina: 9, gatey: 17 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date11).convert(to_h: true)).to eq({ barsa: 2082, mahina: 5, gatey: 16 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date12).convert(to_h: true)).to eq({ barsa: 2082, mahina: 9, gatey: 16 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date13).convert(to_h: true)).to eq({ barsa: 2081, mahina: 10, gatey: 1 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date14).convert(to_h: true)).to eq({ barsa: 2082, mahina: 2, gatey: 19 })
  end

  it "returns equivalent AD for BS chaitra 30" do
    expect(described_class.new(date15).convert(to_h: true)).to eq({ barsa: 2081, mahina: 12, gatey: 30 })
  end

  it "returns equivalent AD for BS" do
    expect(described_class.new(date17).convert(to_h: true)).to eq({ barsa: 2081, mahina: 11, gatey: 3 })
  end
end
