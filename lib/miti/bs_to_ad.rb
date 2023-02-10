# frozen_string_literal: true

module Miti
  # class to handle the algorithm for converting AD to BS
  class BsToAd
    ##
    # Creating an object of BsToAd requires a Miti::NepaliDate object
    #
    # @param [Miti::NepaliDate]
    def initialize(nepali_date)
      @nepali_date = nepali_date
    end

    def convert
      english_date
    end

    private

    attr_reader :nepali_date

    ##
    # Iterates through range of dates close to probable english date and checks to get exact english_date
    # Incase the date is not found, error is raised.
    # For fixing the issue, the value for range in date_range method should be increased.
    #
    # @return [Date]
    def english_date
      current_year = nepali_date.barsa

      english_day_for_naya_barsa = Miti::Data::BAISHKH_FIRST_CORRESPONDING_APRIL[current_year]

      Date.new(current_year - 57, 4, english_day_for_naya_barsa) + nepali_date.yday - 1
    end
  end
end
