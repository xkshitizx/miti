# frozen_string_literal: true

require_relative "../../spec_helper"
require "action_view"
require "action_view/helpers"
require "miti/rails/form_helper"

RSpec.describe Miti::Rails::FormHelper do
  let(:view) { ActionView::Base.empty }
  let(:object_name) { :event }
  let(:method_name) { :happened_on }

  before do
    view.extend(described_class)
  end

  describe "#nepali_date_field" do
    subject(:html) { view.nepali_date_field(object_name, method_name) }

    it "renders a text input" do
      expect(html).to include('type="text"')
    end

    it "includes the Stimulus controller" do
      expect(html).to include('data-controller="miti-date-picker"')
    end

    it "includes the right name attribute" do
      expect(html).to include('name="event[happened_on]"')
    end

    it "targets *_bs when the object exposes BS accessors" do
      object = double(happened_on_bs: nil)
      html = view.nepali_date_field(object_name, method_name, object: object)
      expect(html).to include('name="event[happened_on_bs]"')
    end

    it "has autocomplete off" do
      expect(html).to include('autocomplete="off"')
    end

    it "has a placeholder" do
      expect(html).to include("YYYY-MM-DD")
    end

    it "includes the stimilus actions" do
      expect(html).to include("miti-date-picker")
    end

    context "with a date attribute on the object" do
      it "pre-fills the value" do
        object = double(happened_on: Date.new(2026, 5, 13))
        html = view.nepali_date_field(object_name, method_name, object: object)
        expect(html).to include('value="2083-01-30"')
      end
    end

    context "with explicit value option" do
      it "uses the provided value" do
        html = view.nepali_date_field(object_name, method_name, value: "2080-05-15")
        expect(html).to include('value="2080-05-15"')
      end
    end
  end

  describe "#nepali_date_select" do
    subject(:html) { view.nepali_date_select(object_name, method_name) }

    it "renders year, month, and day select elements" do
      expect(html).to include("miti-date-select__year")
      expect(html).to include("miti-date-select__month")
      expect(html).to include("miti-date-select__day")
    end

    it "uses Rails multiparameter naming" do
      expect(html).to include('name="event[happened_on(1i)]"')
      expect(html).to include('name="event[happened_on(2i)]"')
      expect(html).to include('name="event[happened_on(3i)]"')
    end

    it "targets *_bs multiparameter names when the object exposes BS accessors" do
      object = double(happened_on_bs: nil)
      html = view.nepali_date_select(object_name, method_name, object: object)
      expect(html).to include('name="event[happened_on_bs(1i)]"')
      expect(html).to include('name="event[happened_on_bs(2i)]"')
      expect(html).to include('name="event[happened_on_bs(3i)]"')
    end

    it "includes month names" do
      expect(html).to include("Baisakh")
      expect(html).to include("बैशाख")
    end

    context "with a date attribute on the object" do
      it "pre-selects year, month, day" do
        object = double(happened_on: Date.new(2026, 5, 13))
        html = view.nepali_date_select(object_name, method_name, object: object)
        expect(html).to include('value="2083"') # year
        expect(html).to include('value="1"')    # month
      end
    end
  end

  describe "FormBuilder integration" do
    it "responds to nepali_date_field" do
      expect(ActionView::Helpers::FormBuilder.instance_methods)
        .to include(:nepali_date_field)
    end

    it "responds to nepali_date_select" do
      expect(ActionView::Helpers::FormBuilder.instance_methods)
        .to include(:nepali_date_select)
    end
  end
end
