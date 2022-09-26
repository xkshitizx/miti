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

    attr_reader :date

    def parse_month
      Miti::NepaliDate.months_in_english_font[calculate_year_month_day[:mahina] - 1]
    end

    def parse_day
      @date.strftime("%A")
    end

    def calculate_year_month_day
      @calculate_year_month_day ||= Miti::AdToBs.new(@date).convert
    end

    def date?(date)
      date.match(%r{2022/09/21})
    end

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

      if klass == "String"
        Miti::NepaliDate.parse(nepali_date)
      elsif klass == "Miti::NepaliDate"
        nepali_date
      else
        raise "Invalid date format."
      end
    end
  end
end
