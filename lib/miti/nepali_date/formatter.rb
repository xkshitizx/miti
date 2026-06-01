# frozen_string_literal: true

module Miti
  class NepaliDate
    class InvalidSeparatorError < StandardError; end
    class InvalidFontError < StandardError; end

    # Compares two dates and returns the greater date
    class Formatter
      VALID_SEPERATORS = [" ", "/", "-"].freeze
      VALID_FONTS = %w[english nepali].freeze

      def initialize(nepali_date)
        @nepali_date = nepali_date
        @barsa = nepali_date.barsa
        @mahina = nepali_date.mahina
        @gatey = nepali_date.gatey
      end

      def self.to_s
        new(nepali_date).to_s
      end

      def self.descriptive
        new(nepali_date).descriptive
      end

      ##
      # Returns Nepali Date in string format(yyyy/mm/dd).
      #
      # @param separator(- by default) can be ' ', '/' or '-'
      #
      # @return [String]
      def to_s(separator = "-")
        raise InvalidSeparatorError, "Invalid separator provided." unless VALID_SEPERATORS.include?(separator)

        [barsa, mahina, gatey].reduce("") do |final_date, date_element|
          "#{final_date}#{separator unless final_date.empty?}#{0 if date_element < 10}#{date_element}"
        end
      end

      ##
      # Formats Nepali date with custom tokens.
      #
      # Supported tokens:
      #   %<gatey>g => gatey
      #   %<mahina>m => mahina
      #   %<barsa>b => barsa
      #   %<barsa>Y => barsa
      #   %<month>B => month name
      #   %<weekday>A => weekday name
      #
      # @return [String]
      def format(format_string, nepali: false)
        format_string.gsub(/%(?:<(?<token>gatey|mahina|barsa|month|weekday)>(?<type>[gmbBYA])|(?<legacy>[gmbYAB]))/) do
          token = Regexp.last_match[:token] || Regexp.last_match[:legacy]

          format_token(token, nepali: nepali)
        end
      end

      ##
      # Descriptive output for current date
      # When nepali flag is true, month is returned in nepali font and week day in Nepali
      #
      # @return [String]
      def descriptive(font)
        return send(:"descriptive_#{font}") if VALID_FONTS.include?(font)

        raise InvalidFontError, "Invalid font provided. only english or nepali is allowed"
      end

      private

      attr_reader :barsa, :mahina, :gatey, :nepali_date

      def descriptive_english
        month = months_in_english[mahina - 1]
        week_day = nepali_date.tarik.strftime("%A")

        "#{month} #{gatey}, #{barsa} #{week_day}"
      end

      def descriptive_nepali
        month = months_in_nepali[mahina - 1]
        week_day = week_days_in_nepali[nepali_date.bar]

        "#{month} #{gatey}, #{barsa} #{week_day}"
      end

      def month_name(nepali: false)
        nepali ? months_in_nepali[mahina - 1] : months_in_english[mahina - 1]
      end

      def week_day_name(nepali: false)
        nepali ? week_days_in_nepali[nepali_date.bar] : nepali_date.tarik.strftime("%A")
      end

      def format_token(token, nepali: false)
        case token
        when "g", "gatey"
          gatey.to_s.rjust(2, "0")
        when "m", "mahina"
          mahina.to_s.rjust(2, "0")
        when "b", "barsa", "Y"
          barsa.to_s
        when "B", "month"
          month_name(nepali: nepali)
        when "A", "weekday"
          week_day_name(nepali: nepali)
        else
          token
        end
      end

      def months_in_english
        %w[Baishakh Jestha Ashadh Shrawan Bhadra Asoj Kartik Mangsir Poush Magh Falgun Chaitra]
      end

      def week_days_in_nepali
        %w[आइतबार सोमबार मंगलबार बुधबार बिहिबार शुक्रबार शनिबार]
      end

      def months_in_nepali
        %w[वैशाख ज्येष्ठ आषाढ़ श्रावण भाद्र आश्विन कार्तिक मंसिर पौष माघ फाल्गुण चैत्र]
      end
    end
  end
end
