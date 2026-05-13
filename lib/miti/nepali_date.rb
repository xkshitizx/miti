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
    def descriptive(nepali: false)
      month_index = mahina - 1
      if nepali
        month = NepaliDate.months[month_index]
        week_day = "#{NepaliDate.week_days_in_english[bar]}(#{NepaliDate.week_days[bar]})"
      else
        month = NepaliDate.months_in_english[month_index]
        week_day = tarik.strftime("%A")
      end

      "#{month} #{gatey}, #{barsa} #{week_day}"
    end

    def yday
      days_before_month = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa].first(mahina - 1).sum
      days_before_month + gatey
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
        regex = %r{\A\d{4}[,-/\s]\d{1,2}[,-/\s]\d{1,2}\z}
        raise "Invalid Date Format" unless regex.match(date_string)

        delimiters = ["-", " ", "/", ","]
        barsa, mahina, gatey = date_string.split(Regexp.union(delimiters))
        validate_parsed_date(barsa.to_i, mahina.to_i, gatey.to_i)
        NepaliDate.new(barsa: barsa.to_i, mahina: mahina.to_i, gatey: gatey.to_i)
      end

      private

      def validate_parsed_date(barsa, mahina, gatey)
        raise "Mahina can't be greater than 12" if mahina > 12

        max_day_of_month = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa]&.at(mahina - 1)
        return unless max_day_of_month && max_day_of_month < gatey

        raise "Invalid date. The supplied gatey value exceeds the max available gatey for the mahina."
      end
    end
  end
end
