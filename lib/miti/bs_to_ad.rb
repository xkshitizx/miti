# frozen_string_literal: true

require "date"

module Miti
  # class to handle the algorithm for converting AD to BS
  class BsToAd
    ##
    # Creating an object of BsToAd requires a Miti::NepaliDate object
    #
    # params Miti::NepaliDate
    def initialize(nepali_date)
      @barsa = nepali_date.barsa
      @mahina = nepali_date.mahina
      @gatey = nepali_date.gatey
    end

    def convert
      english_date
    end

    private

    attr_reader :barsa, :mahina, :gatey

    ##
    # Iterates through range of dates close to probable english date and checks to get exact english_date
    # Incase the date is not found, error is raised.
    # For fixing the issue, the value for range in date_range method should be increased.
    #
    # returns Date
    def english_date
      date_range.each do |date|
        return date if Miti::AdToBs.new(date).convert(to_h: true) ==
                       { barsa: barsa, mahina: mahina, gatey: gatey }
      end
      raise "Failed to convert."
    end

    ##
    # Since the obtained date is not exact, range of date (default 17) are returned containing the date.
    # The average gap between nepali year and english date is 20,711 days considering the numericality of months.
    # This method creates new english date with year/month/day value equal to Nepali date and subtracts by 20,711
    # and returns the range of date around it.
    #
    # return []<Date>
    def date_range(range = 8)
      probable_english_date = Date.new(barsa, mahina, gatey) - 20_711
      probable_english_date.prev_day(range)..probable_english_date.next_day(range)
    end
  end
end
