# frozen_string_literal: true

require_relative "../../spec_helper"
require "action_view"
require "miti/rails/date_picker_helper"

RSpec.describe Miti::Rails::DatePickerHelper do
  let(:view) { ActionView::Base.empty }

  before do
    view.extend(described_class)
  end

  describe "#include_miti_date_picker_data" do
    subject(:html) { view.include_miti_date_picker_data }

    it "renders a script tag" do
      expect(html).to include("<script")
      expect(html).to include("</script>")
    end

    it "has the correct id" do
      expect(html).to include('id="miti-calendar-data"')
    end

    it "has application/json type" do
      expect(html).to include('type="application/json"')
    end

    it "includes calendar data" do
      expect(html).to include("nepaliYearMonthHash")
      expect(html).to include("baishakhFirstCorrespondingApril")
      expect(html).to include("monthsEnglish")
      expect(html).to include("monthsNepali")
      expect(html).to include("weekdaysEnglish")
      expect(html).to include("weekdaysNepali")
    end
  end
end
