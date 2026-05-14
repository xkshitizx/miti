# frozen_string_literal: true

require_relative "../../spec_helper"
require "active_model"
require "miti/rails/model_concern"

RSpec.describe Miti::Rails::ModelConcern do
  before do
    stub_const("TestModel", Class.new do
      include ActiveModel::Model
      include Miti::Rails::ModelConcern

      attr_accessor :happened_on

      has_nepali_date :happened_on
    end)
  end

  let(:model) { TestModel.new }

  describe "._bs getter" do
    context "when the attribute is set to an AD date" do
      before do
        model.happened_on = Date.new(2026, 5, 13)
      end

      it "returns the corresponding BS date" do
        bs = model.happened_on_bs
        expect(bs).to be_a(Miti::NepaliDate)
        expect(bs.barsa).to eq(2083)
        expect(bs.mahina).to eq(1)
        expect(bs.gatey).to eq(30)
      end
    end

    context "when the attribute is nil" do
      it "returns nil" do
        expect(model.happened_on_bs).to be_nil
      end
    end
  end

  describe "._bs= setter" do
    context "with a valid BS string" do
      it "sets the AD date on the attribute" do
        model.happened_on_bs = "2083-01-01"
        expect(model.happened_on).to be_a(Date)
        expect(model.happened_on.year).to eq(2026)
      end
    end

    context "with a Miti::NepaliDate" do
      it "sets the AD date on the attribute" do
        nepali_date = Miti::NepaliDate.new(barsa: 2080, mahina: 5, gatey: 15)
        model.happened_on_bs = nepali_date
        expect(model.happened_on).to be_a(Date)
        expect(model.happened_on).to eq(nepali_date.tarik)
      end
    end

    context "with nil" do
      it "sets the attribute to nil" do
        model.happened_on = Date.new(2026, 5, 13)
        model.happened_on_bs = nil
        expect(model.happened_on).to be_nil
      end
    end

    context "with an invalid value" do
      it "raises InvalidNepaliDateError" do
        expect { model.happened_on_bs = 123 }
          .to raise_error(Miti::Rails::ModelConcern::InvalidNepaliDateError)
      end
    end

    context "with an invalid BS date string" do
      it "raises InvalidNepaliDateError" do
        expect { model.happened_on_bs = "not-a-date" }
          .to raise_error(Miti::Rails::ModelConcern::InvalidNepaliDateError)
      end
    end

    context "with a BS date outside the conversion range" do
      it "raises InvalidNepaliDateError" do
        expect { model.happened_on_bs = "2101-01-01" }
          .to raise_error(Miti::Rails::ModelConcern::InvalidNepaliDateError)
      end
    end
  end

  describe "._bs_human" do
    context "when the attribute is set" do
      before do
        model.happened_on = Date.new(2026, 5, 13)
      end

      it "returns a descriptive string" do
        expect(model.happened_on_bs_human).to be_a(String)
        expect(model.happened_on_bs_human).to include("2083")
      end
    end

    context "when the attribute is nil" do
      it "returns nil" do
        expect(model.happened_on_bs_human).to be_nil
      end
    end
  end

  describe "multiple attributes" do
    before do
      stub_const("MultiAttrModel", Class.new do
        include ActiveModel::Model
        include Miti::Rails::ModelConcern

        attr_accessor :start_date, :end_date

        has_nepali_date :start_date, :end_date
      end)
    end

    it "defines BS accessors for all specified attributes" do
      model = MultiAttrModel.new
      model.start_date = Date.new(2026, 1, 1)
      model.end_date = Date.new(2026, 12, 31)

      expect(model.start_date_bs).to be_a(Miti::NepaliDate)
      expect(model.end_date_bs).to be_a(Miti::NepaliDate)
    end
  end
end
