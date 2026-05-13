# frozen_string_literal: true

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
          monthsEnglish: Miti::NepaliDate::MONTHS_IN_ENGLISH,
          monthsNepali: Miti::NepaliDate::MONTHS_IN_NEPALI,
          weekdaysEnglish: Miti::NepaliDate::WEEK_DAYS_IN_ENGLISH,
          weekdaysNepali: Miti::NepaliDate::WEEK_DAYS_IN_NEPALI
        }
      end
    end
  end
end
