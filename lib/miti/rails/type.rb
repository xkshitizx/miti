# frozen_string_literal: true

module Miti
  module Rails
    class Type < ActiveRecord::Type::Date
      def cast(value)
        case value
        when Miti::NepaliDate
          value.tarik
        when String
          Miti.to_ad(value)
        else
          super
        end
      rescue Miti::ConversionUnavailableError, Miti::NepaliDate::FormatError, Miti::NepaliDate::DateRangeError
        nil
      end
    end
  end
end

ActiveRecord::Type.register(:miti_nepali_date, Miti::Rails::Type)
