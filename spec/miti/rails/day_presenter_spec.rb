# frozen_string_literal: true

require_relative "../../spec_helper"
require "miti/rails/calendar/day_presenter"

RSpec.describe Miti::Rails::Calendar::DayPresenter do
  let(:today) { Date.new(2026, 5, 13) }
  let(:nepali_date) { Miti::NepaliDate.new(barsa: 2083, mahina: 1, gatey: 1) }
  let(:presenter) { described_class.new(nepali_date, today: today) }

  describe "#gatey" do
    it "delegates to date" do
      expect(presenter.gatey).to eq(1)
    end
  end

  describe "#barsa" do
    it "delegates to date" do
      expect(presenter.barsa).to eq(2083)
    end
  end

  describe "#mahina" do
    it "delegates to date" do
      expect(presenter.mahina).to eq(1)
    end
  end

  describe "#bar" do
    it "delegates to date" do
      expect(presenter.bar).to be_an(Integer)
    end
  end

  describe "#tarik" do
    it "delegates to date" do
      expect(presenter.tarik).to be_a(Date)
    end
  end

  describe "#today?" do
    context "when the date is today" do
      let(:nepali_date) { Miti.to_bs("2026-05-13") }
      let(:today) { Date.new(2026, 5, 13) }

      it "returns true" do
        expect(presenter.today?).to be(true)
      end
    end

    context "when the date is not today" do
      it "returns false" do
        expect(presenter.today?).to be(false)
      end
    end
  end

  describe "#sunday?" do
    it "returns true when bar is 0" do
      allow(nepali_date).to receive(:bar).and_return(0)
      expect(presenter.sunday?).to be(true)
    end
  end

  describe "#saturday?" do
    it "returns true when bar is 6" do
      allow(nepali_date).to receive(:bar).and_return(6)
      expect(presenter.saturday?).to be(true)
    end
  end

  describe "#to_param" do
    it "returns the date string" do
      expect(presenter.to_param).to eq("2083-01-01")
    end
  end

  describe "#ad_date" do
    it "returns the AD date" do
      expect(presenter.ad_date).to be_a(Date)
      expect(presenter.ad_date).to eq(nepali_date.tarik)
    end
  end
end
