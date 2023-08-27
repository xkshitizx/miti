# frozen_string_literal: true

module Miti
  class NepaliDate
    class FormatError < StandardError; end

    # Compares two dates and returns the greater date
    class Difference
      def initialize(date1, date2)
        @date1 = date1
        @date2 = date2
      end

      def difference
        # find out the greater and smaller date
        assign_greater_and_smaller_date
        @reference_greater_date = calculated_reference_greater_date
        calculate_difference
      end

      private

      attr_reader :date1, :date2, :greater_date, :smaller_date, :reference_greater_date

      def assign_greater_and_smaller_date
        compared_result = Miti::NepaliDate::Comparison.new(date1, date2).compare
        @greater_date = compared_result[:greater_date]
        @smaller_date = compared_result[:smaller_date]
      end

      ##
      # Returns date with year of greater_date or a year earlier with month and day of smaller_date
      #
      # [Examples]
      #  * if greater_date: 2024-12-02 and smaller_date: 2000-05-05, reference_greater_date: 2024-05-05
      #  * if greater_date: 2024-01-02 and smaller_date: 2000-05-05, reference_greater_date: 2023-05-05
      #
      # @return Miti::NepaliDate
      def calculated_reference_greater_date
        greater_date_year = greater_date_barsa
        temp_reference_date = assign_nepali_date(greater_date_year, smaller_date.mahina, smaller_date.gatey)

        return temp_reference_date unless reference_date_is_greater_than_actual_greater_date?(temp_reference_date)

        @greater_date_is_one_more_than_reference_date = true
        assign_nepali_date(greater_date_year - 1, temp_reference_date.mahina, temp_reference_date.gatey)
      end

      def calculate_difference
        {
          years: year_difference,
          months: month_difference,
          days: day_difference,
          total_days: total_days
        }
      end

      def greater_date_barsa
        @greater_date_barsa ||= greater_date.barsa
      end

      def assign_nepali_date(barsa, mahina, gatey)
        NepaliDate.new(barsa: barsa, mahina: mahina, gatey: gatey)
      rescue Miti::NepaliDate::DateRangeError
        # rescue when date doesn't exist. occurs when smaller date has 31 gatey.
        # and the reference date can't have 31. so falls to last day of the month
        NepaliDate.new(barsa: barsa, mahina: mahina, gatey: Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa][mahina - 1])
      end

      def reference_date_is_greater_than_actual_greater_date?(reference_date)
        Miti::NepaliDate::Comparison.new(greater_date, reference_date).compare[:greater_date] == reference_date
      end

      def year_difference
        reference_greater_date.barsa - smaller_date.barsa
      end

      def month_difference
        difference = greater_date.mahina - reference_greater_date.mahina
        difference -= 1 unless reference_gatey_less_than_greater_gatey
        difference += 12 if @greater_date_is_one_more_than_reference_date
        difference
      end

      def day_difference
        difference = greater_date.gatey - reference_greater_date.gatey
        reference_gatey_less_than_greater_gatey ? difference : difference + last_day_of_reference_month
      end

      def total_days
        (greater_date.tarik - smaller_date.tarik).to_i
      end

      def reference_gatey_less_than_greater_gatey
        @reference_gatey_less_than_greater_gatey ||= reference_greater_date.gatey <= greater_date.gatey
      end

      def last_day_of_reference_month
        Miti::Data::NEPALI_YEAR_MONTH_HASH[reference_greater_date.barsa][reference_greater_date.mahina - 1]
      end
    end
  end
end
