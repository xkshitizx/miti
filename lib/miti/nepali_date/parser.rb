# frozen_string_literal: true

module Miti
  class NepaliDate
    class FormatError < StandardError; end

    # This class requires date in yyyy-mm-dd or dd-mm-yyyy format
    # It supports ["/", "-"] as delimiters for year, month and day
    # It parses on initialization but only validates if the parse method is called
    class Parser
      VALID_DELIMITERS = ["-", "/"].freeze
      VALID_FORMATS = %w[dd-mm-yyyy yyyy-mm-dd].freeze

      attr_reader :date_string, :barsa, :mahina, :gatey, :delimiter, :validated

      ##
      # Format should be yyyy-mm-dd or dd-mm-yyyy
      # NOTE: mahina, gatey and barsa are generated in initialization but ARE NOT VALIDATED
      #
      # @param date_string [String]
      def initialize(date_string)
        @date_string = date_string.delete(" ")
        @validated = false
        parse_delimiter_and_date_units
      end

      ##
      # This method parses date in yyyy/mm/dd to NepaliDate object
      #
      # @return [Miti::NepaliDate]
      def parse
        Miti::NepaliDate::Validator.validate!(barsa, mahina, gatey)
        NepaliDate.new(barsa: barsa.to_i, mahina: mahina.to_i, gatey: gatey.to_i)
      end

      private

      def parse_delimiter_and_date_units
        @delimiter = date_string[delimiter_index]
        parse_miti
      end

      def delimiter_index
        index = date_string.index(Regexp.union(VALID_DELIMITERS))
        return index if [2, 4].include?(index)

        raise FormatError, "Date format should be yyyy-mm-dd or dd-mm-yyyy separated by - or /"
      end

      def parse_miti
        date_elements = date_string.split(delimiter).map(&:to_i)
        raise FormatError, "All year, month and day should be supplied" unless date_elements.size == 3

        @barsa = date_elements.max
        @mahina = date_elements[1] # always in the middle
        @gatey = date_elements.index(barsa).zero? ? date_elements[2] : date_elements[0]
      end
    end
  end
end
