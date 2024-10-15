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

    # Return equivalent english date for nepali date
    def convert
      corresponding_ad_for_baisakh1 + days_to_be_added_from_baisakh1
    end

    private

    attr_reader :nepali_date

    ##
    # Returns corresponding AD for baisakh first of nepali year
    def corresponding_ad_for_baisakh1
      current_year = nepali_date.barsa
      baisakh1_corresponding_ad = Miti::Data::BAISHKH_FIRST_CORRESPONDING_APRIL[current_year]
      # AD is 57 years ahead of BS and always in April
      Date.new(current_year - 57, 4, baisakh1_corresponding_ad)
    end

    def days_to_be_added_from_baisakh1
      nepali_date.yday - 1
    end
  end
end
