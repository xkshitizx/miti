# frozen_string_literal: true

module Miti
  class CalendarDataController < ActionController::Base
    skip_before_action :verify_authenticity_token, only: :show

    def show
      render json: calendar_data.merge(cssPath: helpers.asset_path("miti/calendar.css"))
    end

    private

    def calendar_data
      {
        nepaliYearMonthHash: Miti::Data::NEPALI_YEAR_MONTH_HASH.transform_keys(&:to_s),
        baishakhFirstCorrespondingApril: Miti::Data::BAISHKH_FIRST_CORRESPONDING_APRIL.transform_keys(&:to_s),
        janFirstCorrespondingGatey: Miti::Data::JAN_FIRST_CORRESPONDING_GATEY.transform_keys(&:to_s),
        monthsEnglish: Miti::NepaliDate.months_in_english,
        monthsNepali: Miti::NepaliDate.months,
        weekdaysEnglish: Miti::NepaliDate.week_days_in_english,
        weekdaysNepali: Miti::NepaliDate.week_days
      }
    end
  end
end
