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
      day_count_from_beginning_of_poush = 1 - day
      nepali_date = corresponding_nepali_date(year, month - 1, day_count_from_beginning_of_poush)
      Miti::NepaliDate.new(**nepali_date)
    end

    private

    attr_reader :english_date

    ##
    # Returns the corresponding **Nepali Date** for **English new year**.
    # **year** is added by *56* and **month** is always *9(poush)*
    #
    # @return Array, refers to [year, month, day] of nepali calendar
    def nepali_date_for_new_year
      year = english_date.year
      jan_first_corresponding_gatey = Miti::Data::JAN_FIRST_CORRESPONDING_GATEY[year]
      [year + 56, 9, jan_first_corresponding_gatey]
    end

    ##
    # Returns corresponding nepali date for specific english date.
    #
    # @param **year**<Integer>, Refers to nepali year
    # @param **base_month_index**<Integer>, Refers to index of month(eg: 1 for Baisakh)
    # @param **day_count_from_beginning_of_poush**<Integer>, Refers to number of days from poush
    #
    # @return [Hash], hash consisting (:barsa, :mahina, :gatey)
    def corresponding_nepali_date(year, base_month_index, day_count_from_beginning_of_poush)
      nepali_year_month_hash[year][base_month_index..].each_with_index do |days_in_month, index|
        counted_days = day_count_from_beginning_of_poush + days_in_month
        next day_count_from_beginning_of_poush += days_in_month if counted_days < yth_day

        barsa_mahina = { barsa: year, mahina: index + base_month_index + 1 }
        return barsa_mahina.merge(gatey: days_in_month) if counted_days == yth_day

        return barsa_mahina.merge(gatey: yth_day - day_count_from_beginning_of_poush)
      end

      corresponding_nepali_date(year + 1, 0, day_count_from_beginning_of_poush)
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
    def yth_day
      @yth_day ||= english_date.yday
    end
  end
end
