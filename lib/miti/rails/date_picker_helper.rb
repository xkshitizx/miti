# frozen_string_literal: true

require "json"

module Miti
  module Rails
    module DatePickerHelper
      def include_miti_date_picker_data
        tag.script(
          miti_calendar_data.to_json,
          id: "miti-calendar-data",
          type: "application/json"
        )
      end

      def miti_date_picker_data
        miti_calendar_data
      end

      private

      def miti_calendar_data
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
end
