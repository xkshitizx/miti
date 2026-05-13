# frozen_string_literal: true

module Miti
  module Rails
    module ModelConcern
      extend ActiveSupport::Concern

      class InvalidNepaliDateError < StandardError; end

      module ClassMethods
        def has_nepali_date(*attrs)
          attrs.each do |attr|
            define_bs_getter(attr)
            define_bs_setter(attr)
            define_bs_human(attr)
          end
        end

        private

        def define_bs_getter(attr)
          define_method :"#{attr}_bs" do
            ad_date = public_send(attr)
            Miti.to_bs(ad_date) if ad_date
          rescue Miti::ConversionUnavailableError
            nil
          end
        end

        def define_bs_setter(attr)
          define_method :"#{attr}_bs=" do |value|
            case value
            when Miti::NepaliDate
              public_send(:"#{attr}=", value.tarik)
            when String
              nepali_date = Miti::NepaliDate.parse(value)
              public_send(:"#{attr}=", Miti.to_ad(nepali_date))
            when nil
              public_send(:"#{attr}=", nil)
            else
              raise InvalidNepaliDateError,
                    "Expected Miti::NepaliDate, String, or nil, got #{value.class}"
            end
          rescue ArgumentError, Miti::ConversionUnavailableError => e
            raise InvalidNepaliDateError, e.message
          end
        end

        def define_bs_human(attr)
          define_method :"#{attr}_bs_human" do
            nepali_date = public_send(:"#{attr}_bs")
            return nil unless nepali_date

            nepali_date.descriptive(nepali: I18n.locale == :ne)
          end
        end
      end
    end
  end
end
