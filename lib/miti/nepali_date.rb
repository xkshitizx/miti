# frozen_string_literal: true

require_relative "data/date_data"

module Miti
  # Class for nepali date
  class NepaliDate
    include Comparable

    MONTHS_IN_NEPALI = %w[बैशाख जेठ असार साउन भदौ असोज कार्तिक मंसिर पुष माघ फागुन चैत].freeze
    MONTHS_IN_ENGLISH = %w[Baisakh Jestha Ashadh Shrawan Bhadra Asoj Kartik Mangsir Poush Magh Falgun Chaitra].freeze
    WEEK_DAYS_IN_NEPALI = %w[आइतबार सोमबार मंगलबार बुधबार बिहिबार शुक्रबार शनिबार].freeze
    WEEK_DAYS_IN_ENGLISH = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
    attr_reader :barsa, :mahina, :gatey

    def <=>(other)
      return nil unless other.is_a?(NepaliDate)

      [barsa, mahina, gatey] <=> [other.barsa, other.mahina, other.gatey]
    end

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
        month = MONTHS_IN_NEPALI[month_index]
        week_day = "#{WEEK_DAYS_IN_ENGLISH[bar]}(#{WEEK_DAYS_IN_NEPALI[bar]})"
      else
        month = MONTHS_IN_ENGLISH[month_index]
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

      def months
        MONTHS_IN_NEPALI
      end

      def months_in_english
        MONTHS_IN_ENGLISH
      end

      def week_days
        WEEK_DAYS_IN_NEPALI
      end

      def week_days_in_english
        WEEK_DAYS_IN_ENGLISH
      end

      ##
      # This method parses date in yyyy/mm/dd to NepaliDate object
      #
      # @return [Miti::NepaliDate]
      def parse(date_string)
        parser = Miti::NepaliDate::Parser.new(date_string)
        unless parser.date_string.match?(%r{\A\d{4}[-/]})
          raise Miti::NepaliDate::FormatError, "Date format should be yyyy-mm-dd separated by - or /"
        end

        parser.parse
      end
    end
  end
end
