# frozen_string_literal: true

module Miti
  module Cli
    # calculates first day of next month
    class Next
      def initialize(nepali_date)
        @current_date = nepali_date
        @current_mahina = nepali_date.mahina
        @current_barsa = nepali_date.barsa
        @current_gatey = nepali_date.gatey
      end

      def calculate
        [days_left_description, current_month_last_description]
      end

      private

      attr_reader :current_date, :current_barsa, :current_mahina, :current_gatey

      def days_left_description
        "\n#{days_left} days left until #{next_month_first.descriptive}"
      end

      def current_month_last_description
        "Current month's last date => #{last_gatey_this_month}-#{end_of_month.descriptive}"
      end

      def days_left
        NepaliDate::Difference.new(next_month_first, current_date).difference[:days]
      end

      def next_month_first
        @next_month_first ||= begin
          month, year = current_mahina < 12 ? [current_mahina + 1, current_barsa] : [1, current_barsa + 1]
          NepaliDate.new(barsa: year, mahina: month, gatey: 1)
        end
      end

      def end_of_month
        @end_of_month ||= NepaliDate.new(
          barsa: current_barsa, mahina: current_mahina, gatey: last_gatey_this_month
        )
      end

      def last_gatey_this_month
        Miti::Data::NEPALI_YEAR_MONTH_HASH[current_barsa][current_mahina - 1]
      end
    end
  end
end
