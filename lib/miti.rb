# frozen_string_literal: true

require "date"
require_relative "miti/ad_to_bs"
require_relative "miti/bs_to_ad"
require_relative "miti/nepali_date"
require_relative "miti/data/date_data"
require_relative "miti/nepali_date/parser"
require_relative "miti/nepali_date/validator"
require_relative "miti/nepali_date/comparison"
require_relative "miti/nepali_date/difference"
require_relative "miti/nepali_date/formatter"

# Base module for the gem
module Miti
  class Error < StandardError; end
  class ConversionUnavailableError < StandardError; end

  class << self
    ##
    # This method converts the provided english date to nepali date
    # @param english_date [String, Date, Time, DateTime], refers to date
    # @return [<Miti::NepaliDate>], refers to the converted nepali date
    def to_bs(english_date)
      date = parse_english_date(english_date)
      validate_date_range(date: date, conversion: :to_bs)

      Miti::AdToBs.new(date).convert
    rescue ArgumentError
      "Invalid Date"
    end

    ##
    # This method converts the provided nepali date to english date
    # @param nepali_date [String, Miti::NepaliDate], refers to date
    # @return [<Date>], refers to the converted english date from nepali date
    def to_ad(nepali_date)
      validate_date_range(date: nepali_date, conversion: :to_ad)
      date = parse_nepali_date(nepali_date)

      Miti::BsToAd.new(date).convert
    end

    ##
    # Computes the difference between two Nepali dates.
    #
    # @param date1 [String] First Nepali date in YYYY-MM-DD format
    # @param date2 [String] Second Nepali date in YYYY-MM-DD format
    # @return [Hash] Difference with keys :years, :months, :days, :total_days
    def differentiate(date1, date2)
      first_date = Miti::NepaliDate.parse(date1)
      second_date = Miti::NepaliDate.parse(date2)
      Miti::NepaliDate::Difference.new(first_date, second_date).differentiate
    end

    private

    ##
    # Extracts the year from various date-like objects
    def year_from_date(date)
      case date
      when Date then date.year
      when Miti::NepaliDate then date.barsa
      when String
        matched_year = date.match(%r{\A(\d{4})[-/ ]}) || date.match(/\A(\d{4}),/)
        raise ArgumentError, "Invalid date format." unless matched_year

        matched_year[1].to_i
      else
        raise ArgumentError, "Invalid date format."
      end
    end

    ##
    # This method throws an exception if the conversion is not available
    # for both BS and AD
    # - For AD to BS conversion max conversion is supported upto 2044 AD
    # - For BS to AD conversion max conversion is supported upto 2100 BS
    # @param date [Date, Miti::NepaliDate], refers to parsed date object
    # @param conversion, [Symbol], refers to the conversion either :to_ad or :to_bs
    #
    # @return ConversionUnavailableError

    def validate_date_range(date:, conversion:)
      max_conversion_year, min_conversion_year, date_format = if conversion == :to_bs
                                                                [2044, 1919, :AD]
                                                              else
                                                                [2100, 1975, :BS]
                                                              end
      year_value = year_from_date(date)
      return if year_value.between?(min_conversion_year, max_conversion_year)

      raise ConversionUnavailableError,
            "Conversion only available for #{min_conversion_year}-#{max_conversion_year} #{date_format}"
    end

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
      when "Miti::NepaliDate"
        nepali_date
      else
        raise "Invalid date format."
      end
    end
  end
end
