# frozen_string_literal: true

require_relative "miti/version"
require "zeitwerk"
require "date"

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

# Base module for the gem
module Miti
  class Error < StandardError; end

  class << self
    def to_bs(english_date)
      date = parse_english_date(english_date)
      Miti::AdToBs.new(date).convert
    rescue Date::Error
      "Invalid Date"
    end

    def to_ad(nepali_date)
      date = parse_nepali_date(nepali_date)
      Miti::BsToAd.new(date).convert
    end

    private

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
