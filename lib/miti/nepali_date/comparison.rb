# frozen_string_literal: true

module Miti
  class NepaliDate
    class FormatError < StandardError; end

    # Compares two dates and returns the greater date
    class Comparison
      attr_reader :greater_date, :smaller_date

      def initialize(date1, date2)
        @date1 = date1
        @date2 = date2
      end

      def compare
        %w[barsa mahina gatey].each do |date_unit|
          return send("assign_by_#{date_unit}".to_sym) if date1.send(date_unit.to_sym) != date2.send(date_unit.to_sym)
        end
        { greater_date: date1, smaller_date: date2, remarks: "Equal dates" }
      end

      private

      # creates 3 methods assign_by_barsa, assign_by_mahina, assign_by_gatey
      %w[barsa mahina gatey].each do |date_unit|
        define_method("assign_by_#{date_unit}") do
          if date1.send(date_unit.to_sym) > date2.send(date_unit.to_sym)
            { greater_date: date1, smaller_date: date2 }
          else
            { greater_date: date2, smaller_date: date1 }
          end
        end
      end

      attr_reader :date1, :date2, :year_gap
    end
  end
end
