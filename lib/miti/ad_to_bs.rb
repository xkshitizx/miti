# frozen_string_literal: true

module Miti
  # class to handle the algorithm for converting AD to BS
  class AdToBs
    ##
    # Initializes a AdToBs object
    # @param @english_date [Date]
    def initialize(english_date)
      @english_date = english_date
    end

    ##
    # Converts the @english_date to nepali date
    #
    # @return [Miti::NepaliDate]
    def convert
      year, month, day = nepali_date_for_new_year
      # Jan 1 can be poush 16, 17 or 18. The gatey obtained has to be subtracted because
      # days in month is added in days calculation and jan 1 is in mid poush.
      day_count_from_poush1 = 1 - day
      nepali_date = corresponding_nepali_date(year, month - 1, day_count_from_poush1)
      Miti::NepaliDate.new(**nepali_date)
    end

    private

    attr_reader :english_date

    ##
    # Returns the corresponding **Nepali Date** for **Jan 1st**.
    #
    # @return Array, refers to [year, month, day] of nepali calendar
    def nepali_date_for_new_year
      year = english_date.year
      jan_first_corresponding_gatey = Miti::Data::JAN_FIRST_CORRESPONDING_GATEY[year]

      # year is added by 56 and month is always 9(poush) for jan 1
      [year + 56, 9, jan_first_corresponding_gatey]
    end

    ##
    # Returns corresponding nepali date for specific english date.
    #
    # @param **year**<Integer>, Refers to nepali year
    # @param **start_month_index**<Integer>, Refers to index of month(eg: 1 for Baisakh)
    # @param **day_count_from_poush1**<Integer>, Refers to number of days from poush
    #
    # @return [Hash], hash consisting (:barsa, :mahina, :gatey)
    def corresponding_nepali_date(year, start_month_index, day_count_from_poush1)
      # start_month_index can be 8(poush) or 0(baisakh)
      nepali_year_month_hash[year][start_month_index..].each_with_index do |days_in_month, month_index|
        # keep track of number of days counted
        counted_days = day_count_from_poush1 + days_in_month
        # keep iterating if counted days is less than days to count.
        next day_count_from_poush1 += days_in_month if counted_days < days_to_count

        # the day is days_in_month if counted and days to count are equal. Else extra days should be subtracted.
        calculated_gatey = counted_days == days_to_count ? days_in_month : days_to_count - day_count_from_poush1
        return { barsa: year, mahina: month_index + start_month_index + 1, gatey: calculated_gatey }
      end

      # If corresponding date does not lie within chaitra, method does not return from loop above.
      # So, the method is recursively called with next year's new year date.
      corresponding_nepali_date(year + 1, 0, day_count_from_poush1)
    end

    ##
    # Returns year_month hash from date_data
    #
    # @return Hash
    def nepali_year_month_hash
      @nepali_year_month_hash ||= Miti::Data::NEPALI_YEAR_MONTH_HASH
    end

    ##
    # Returns number specifying **Nth english date** after **Jan 1st** in specific year
    #
    # @return Integer
    def days_to_count
      @days_to_count ||= english_date.yday
    end
  end
end
