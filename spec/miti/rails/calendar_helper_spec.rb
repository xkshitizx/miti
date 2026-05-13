# frozen_string_literal: true

require_relative "../../spec_helper"
require "action_view"
require "action_view/testing/resolvers"
require "active_support/core_ext/object/to_query"
require "miti/rails/calendar_helper"
require "miti/rails/calendar/day_presenter"

class CalendarTestView < ActionView::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper
  include Miti::Rails::CalendarHelper

  def url_for(options = {})
    "?#{options.to_query}"
  end

  def request
    nil
  end
end

RSpec.describe Miti::Rails::CalendarHelper do
  subject(:view) { CalendarTestView.empty }

  describe "#nepali_calendar" do
    subject(:html) { view.nepali_calendar(year: 2080, month: 1, turbo_frame: nil) }

    it "renders a table with miti-calendar class" do
      expect(html).to include('class="miti-calendar"')
    end

    it "renders the month and year in the title" do
      expect(html).to include("Baishakh 2080")
    end

    it "renders navigation links" do
      expect(html).to include("miti-calendar__nav-link")
    end

    it "renders day cells with gatey" do
      expect(html).to include("miti-calendar__gatey")
      expect(html).to include("miti-calendar__ad-date")
    end

    it "renders weekday header abbreviations" do
      expect(html).to include("Sun")
      expect(html).to include("Mon")
    end
  end

  describe "#nepali_calendar with block" do
    it "yields a DayPresenter to the block" do
      html = view.nepali_calendar(year: 2080, month: 1, turbo_frame: nil) do |day|
        view.tag.span(day.gatey, class: "custom-day")
      end
      expect(html).to include('class="custom-day"')
    end
  end

  describe "#nepali_calendar_agenda" do
    subject(:html) do
      view.nepali_calendar_agenda("2080-01-01", "2080-01-07", group_by: :week)
    end

    it "renders agenda sections" do
      expect(html).to include("miti-agenda__group")
    end

    it "renders agenda headers" do
      expect(html).to include("miti-agenda__header")
    end

    it "renders agenda items" do
      expect(html).to include("miti-agenda__item")
    end

    it "shows BS and AD dates" do
      expect(html).to include("miti-agenda__bs")
      expect(html).to include("miti-agenda__ad")
    end
  end

  describe "#nepali_calendar_agenda with block" do
    it "yields a DayPresenter to the block" do
      html = view.nepali_calendar_agenda("2080-01-01", "2080-01-03", group_by: :week) do |day|
        view.tag.span(day.descriptive, class: "custom-agenda-content")
      end
      expect(html).to include("custom-agenda-content")
    end
  end
end
