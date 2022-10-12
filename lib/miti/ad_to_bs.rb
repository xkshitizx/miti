# frozen_string_literal: true

module Miti
  # class to handle the algorithm for converting AD to BS
  class AdToBs
    ##
    # Initializes a AdToBs object
    # @param @english_date [Date]
    #
    def initialize(english_date)
      @english_date = english_date
      @nepali_year = english_date.year + 56
    end

    ##
    # Converts the @english_date to nepali date
    # @param to_h [boolean], default set to false
    #
    # @return <NepaliDate>, refers to converted nepali date object
    # @return [Hash], hash consisting (:barsa, :mahina, :gatey) if @params to_h is true
    def convert(to_h: false)
      return NepaliDate.new(barsa: final_nepali_year_month_value[:year], mahina: mahina, gatey: gatey) unless to_h

      { barsa: final_nepali_year_month_value[:year], mahina: mahina, gatey: gatey }
    end

    private

    attr_reader :english_date, :nepali_year

    ##
    # Calculates the nepalese year and month respectively
    # determines the difference of nepali_nth_day and total_days_in_nepali_year
    #
    # if the difference is positive
    # - month -> @english_date's month - 4 = nepali_month
    # - year -> @english_date's year + 1 = nepali year
    #
    # if negative
    # - month -> @english_date's month + 8 = nepali_month
    # - year -> @english_date's year = nepali year
    #
    # @return [Hash],which includes (:year,:month) *[converted to nepali]*
    def final_nepali_year_month_value
      @final_nepali_year_month_value = if (nepali_nth_day - total_days_in_nepali_year).positive?
                                         { year: nepali_year + 1, month: english_date.month - 4 }
                                       else
                                         { year: nepali_year, month: english_date.month + 8 }
                                       end
    end

    def mahina
      days_passed = mahina_gatey[:days_passed_in_current_month]
      current_month_max_day = mahina_gatey[:current_month_max_day]
      probable_nepali_month = mahina_gatey[:probable_nepali_month]
      return probable_nepali_month += 1 if days_passed.positive?

      probable_nepali_month += 1 unless current_month_max_day.zero? || days_passed <= current_month_max_day
      probable_nepali_month
    end

    def gatey
      days_passed = mahina_gatey[:days_passed_in_current_month]
      current_month_max_day = mahina_gatey[:current_month_max_day]
      days_passed -= current_month_max_day if days_passed.positive? && days_passed > current_month_max_day
      return days_passed if days_passed.positive?

      return current_month_max_day - days_passed.abs if days_passed.negative?

      current_month_max_day if days_passed.zero?
    end

    def mahina_gatey
      @mahina_gatey ||= begin
        probable_nepali_month = final_nepali_year_month_value[:month]
        month_max_days_upto_current = year_data[final_nepali_year_month_value[:year]].first(probable_nepali_month)
        { probable_nepali_month: probable_nepali_month,
          days_passed_in_current_month: remaining_days_in_nepali_year - month_max_days_upto_current.sum,
          current_month_max_day: month_max_days_upto_current[probable_nepali_month - 1] || 0 }
      end
    end

    ##
    # Calculates the remaining days in a specific year
    # by retrieving the modulo of nepali_nth_day to total_days_in_nepali_year
    # - nepali_nth_day -> number of days from 1st Jan
    # - total_days_in_nepali_year -> number of days in specific nepali year
    #
    # @return [Integer], refers to number of days remaining in nepali year
    def remaining_days_in_nepali_year
      remaining_days = nepali_nth_day % total_days_in_nepali_year
      if remaining_days.zero?
        total_days_in_nepali_year
      else
        remaining_days
      end
    end

    ##
    # Calculates the total number of days in a specific year
    #
    # @return [Integer], refers to the total number of days
    def total_days_in_nepali_year
      @total_days_in_nepali_year ||= year_data[nepali_year].sum
    end

    ##
    # Calculates the number of days in nepali year as on from Jan 1st
    #
    # @return [Integer], refers to number of days
    def nepali_nth_day
      @nepali_nth_day = english_date.yday + nepali_nth_day_for_english_new_year - 1
    end

    ##
    # Determines the number of days from Jan 1st to Baisakh 1st, for leap years
    # - 263 days for normal year
    # - 264 days for year following the leap years
    # @return [Integer], refers to the number of days
    def nepali_nth_day_for_english_new_year
      return 264 if year_after_leap_year?

      263
    end

    ##
    # Checks the previous year of @english_date from params is leap year or not?
    #
    # @return [Boolean], refers previous year is whether leap year or not
    def year_after_leap_year?
      year_before = english_date.year - 1
      (year_before % 400).zero? || (year_before % 100 != 0 && (year_before % 4).zero?)
    end

    ##
    # Calls DateData class to retrieve the nepali date data consisting total no of days, month
    #
    # @return [Hash], refers to hash object consisting the nepali date data
    def year_data
      @year_data = Miti::Data::DateData.year_month_days_hash
    end
  end
end
