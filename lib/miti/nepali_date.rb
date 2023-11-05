# frozen_string_literal: true

require_relative "data/date_data"

module Miti
  # Class for nepali date
  class NepaliDate
    attr_reader :barsa, :mahina, :gatey

    ##
    # require barsa, mahina and gatey as attributes
    def initialize(barsa:, mahina:, gatey:)
      @barsa = barsa
      @mahina = mahina
      @gatey = gatey

      Miti::NepaliDate::Validator.validate!(barsa, mahina, gatey)
    end

    ##
    # Get equivalent tarik(AD) for NepaliDate
    #
    # @return [Date]
    def tarik
      @tarik ||= BsToAd.new(self).convert
    end

    ##
    # Get weekday for a nepali date.
    #
    # @return [Integer](0-6) that represents weekdays starting from 0.
    def bar
      @bar ||= tarik&.wday
    end

    ##
    # returns details of nepali date in a ruby Hash
    #
    # @return [Hash]
    def to_h
      { barsa: barsa, mahina: mahina, gatey: gatey, bar: bar, tarik: tarik }
    end

    ##
    # Returns Nepali Date in string format(yyyy/mm/dd).
    #
    # @param separator(- by default)
    #
    # @return [String]
    def to_s(separator: "-")
      Miti::NepaliDate::Formatter.new(self).to_s(separator)
    end

    ##
    # Descriptive output for current date
    # When nepali flag is true, month is returned in nepali font and week day in Nepali
    #
    # @return [String]
    def descriptive(font = "english")
      Miti::NepaliDate::Formatter.new(self).descriptive(font)
    end

    def yday
      days_before_month = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa].first(mahina - 1).sum
      days_before_month + gatey
    end

    def next_month_first
      current_year_calendar = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa]
      next_month = mahina < 12 ? mahina : 0
      antim_gatey = current_year_calendar[mahina - 1]

      {
        days_left: antim_gatey - gatey + 1,
        month_name: NepaliDate.months_in_english[next_month],
        antim_gatey: "#{antim_gatey} #{NepaliDate.months_in_english[mahina - 1]}"
      }
    end

    class << self
      def today
        AdToBs.new(Date.today).convert
      end

      ##
      # This method parses date in yyyy/mm/dd to NepaliDate object
      #
      # @return [Miti::NepaliDate]
      def parse(date_string)
        Miti::NepaliDate::Parser.new(date_string).parse
      end
    end
  end
end
