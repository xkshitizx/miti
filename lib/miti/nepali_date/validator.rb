# frozen_string_literal: true

module Miti
  class NepaliDate
    class DateRangeError < StandardError; end

    ##
    # Class to validate date range
    class Validator
      class << self
        def validate!(barsa, mahina, gatey)
          validate_barsa(barsa)
          validate_mahina(mahina)
          validate_gatey(mahina, barsa, gatey)
        end

        def valid?(barsa, mahina, gatey)
          validate!(barsa, mahina, gatey)
          true
        rescue DateRangeError
          false
        end

        ##
        # Barsa should range from 1975 to 2100
        def validate_barsa(barsa)
          min_year, max_year = Miti::Data::BAISHKH_FIRST_CORRESPONDING_APRIL.keys.minmax
          return if barsa.between?(min_year, max_year)

          raise DateRangeError, "Year should be between #{min_year} and #{max_year}"
        end

        ##
        # Mahina should not be less than 1 and  greater than 12
        def validate_mahina(mahina)
          raise DateRangeError, "Month should range from 1 to 12" unless mahina.between?(1, 12)
        end

        ##
        # Gatey should be greater than 0 and not exceed max available gatey for given month and year
        def validate_gatey(mahina, barsa, gatey)
          raise DateRangeError, "Day(gatey) should not be zero" if gatey.zero?

          max_day_of_month = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa][mahina - 1]
          return @validated = true if gatey <= max_day_of_month

          raise DateRangeError,
                "The supplied gatey value exceeds the max available gatey(#{max_day_of_month}) for the mahina."
        end
      end
    end
  end
end
