# frozen_string_literal: true

require "date"
require_relative "miti/ad_to_bs"
require_relative "miti/bs_to_ad"
require_relative "miti/nepali_date"

# Base module for the gem
module Miti
  class Error < StandardError; end

  class << self
    ##
    # This method converts the provided english date to nepali date
    # @param english_date [String], refers to date in string format
    # @return [<Miti::NepaliDate>], refers to the converted nepali date
    def to_bs(english_date)
      date = parse_english_date(english_date)
      Miti::AdToBs.new(date).convert
    rescue Date::Error
      "Invalid Date"
    end

    ##
    # This method converts the provided nepali date to english date
    # @param nepali_date [String], refers to date in string format
    # @return [<Date>], refers to the converted english date from nepali date
    def to_ad(nepali_date)
      date = parse_nepali_date(nepali_date)
      Miti::BsToAd.new(date).convert
    end

    private

    ##
    # This method parses the provided parameter english date to Date object
    # It checks the class of the parameter and returns the Date object accordingly
    # @param english_date [String], refers to date in string format OR
    # @param english_date [Date], refers to date object
    # @return [<Date>], refers to Date object
    def parse_english_date(english_date)
      klass = english_date.class.to_s

      if %w[Time DateTime].include?(klass)
        english_date.to_date
      elsif klass == "String"
        Date.parse(english_date)
      else
        english_date
      end
    end

    ##
    # This method parses the provided parameter nepali_date to Miti::NepaliDate object
    # It checks the class of the parameter and returns the Miti::NepaliDate object accordingly
    # @param nepali_date [String], refers to date in string format OR
    # @param nepali_date [Miti::NepaliDate ], refers to date object
    # @return [<Date>], refers to Date object
    def parse_nepali_date(nepali_date)
      klass = nepali_date.class.to_s

      case klass
      when "String"
        Miti::NepaliDate.parse(nepali_date)
      when klass == "Miti::NepaliDate"
        nepali_date
      else
        raise "Invalid date format."
      end
    end
  end
end
