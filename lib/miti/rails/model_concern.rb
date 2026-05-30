# frozen_string_literal: true

module Miti
  module Rails
    module ModelConcern
      extend ActiveSupport::Concern

      class InvalidNepaliDateError < StandardError; end

      GETTER_ERRORS = [
        Miti::NepaliDate::FormatError,
        Miti::NepaliDate::DateRangeError,
        Miti::ConversionUnavailableError
      ].freeze

      CONVERSION_ERRORS = [
        ArgumentError,
        Miti::ConversionUnavailableError,
        Miti::NepaliDate::FormatError,
        Miti::NepaliDate::DateRangeError
      ].freeze

      module ClassMethods
        def has_nepali_date(*attrs, store_bs: false)
          attrs.each do |attr|
            # In store_bs mode, *_bs is the BS input/output surface and the AD column
            # should keep its native type to avoid ambiguous String casting.
            attribute attr, :miti_nepali_date if respond_to?(:attribute) && !store_bs
            define_bs_getter(attr, store_bs: store_bs)
            define_bs_setter(attr)
            define_bs_human(attr)
            define_bs_sync(attr, store_bs: store_bs)
          end
        end

        private

        def define_bs_getter(attr, store_bs: false)
          define_method :"#{attr}_bs" do
            if store_bs
              raw = _miti_read_persisted_bs(attr)
              return Miti::NepaliDate.parse(raw) if raw
            end

            _miti_to_bs(public_send(attr))
          rescue *Miti::Rails::ModelConcern::GETTER_ERRORS
            nil
          end
        end

        def define_bs_setter(attr)
          define_method :"#{attr}_bs=" do |value|
            _miti_write_raw_bs(attr, value)
            _miti_assign_ad_from_bs(attr, value)
          rescue *Miti::Rails::ModelConcern::CONVERSION_ERRORS => e
            raise InvalidNepaliDateError, e.message, cause: e
          end
        end

        def define_bs_human(attr)
          define_method :"#{attr}_bs_human" do
            nepali_date = public_send(:"#{attr}_bs")
            return nil unless nepali_date

            nepali_date.descriptive(nepali: I18n.locale == :ne)
          end
        end

        def define_bs_sync(attr, store_bs: false)
          return unless respond_to?(:before_validation)

          before_validation do
            if public_send(attr).nil?
              bs_val = _miti_read_raw_bs(attr)
              bs_val = _miti_read_persisted_bs(attr) if bs_val.nil?
              _miti_assign_ad_from_bs(attr, bs_val, strict: false) if bs_val.present?
            end

            _miti_sync_persisted_bs(attr) if store_bs
          rescue *Miti::Rails::ModelConcern::CONVERSION_ERRORS
            nil
          ensure
            _miti_clear_raw_bs(attr)
          end
        end
      end

      private

      def _miti_raw_bs_ivar(attr)
        :"@_miti_raw_bs_#{attr}"
      end

      def _miti_write_raw_bs(attr, value)
        raw = case value
              when String then value
              when Miti::NepaliDate then value.to_s
              end
        instance_variable_set(_miti_raw_bs_ivar(attr), raw)
      end

      def _miti_read_raw_bs(attr)
        instance_variable_get(_miti_raw_bs_ivar(attr))
      end

      def _miti_clear_raw_bs(attr)
        instance_variable_set(_miti_raw_bs_ivar(attr), nil)
      end

      def _miti_read_persisted_bs(attr)
        if respond_to?(:read_attribute)
          read_attribute(:"#{attr}_bs")
        else
          instance_variable_get(:"@#{attr}_bs")
        end
      end

      def _miti_write_persisted_bs(attr, raw)
        if respond_to?(:write_attribute)
          write_attribute(:"#{attr}_bs", raw)
        else
          instance_variable_set(:"@#{attr}_bs", raw)
        end
      end

      def _miti_to_bs(ad_date)
        Miti.to_bs(ad_date) if ad_date
      end

      def _miti_sync_persisted_bs(attr)
        raw = _miti_to_bs(public_send(attr))&.to_s
        _miti_write_persisted_bs(attr, raw)
      end

      def _miti_assign_ad_from_bs(attr, value, strict: true)
        case value
        when Miti::NepaliDate
          public_send(:"#{attr}=", value.tarik)
        when String
          nepali_date = Miti::NepaliDate.parse(value)
          public_send(:"#{attr}=", Miti.to_ad(nepali_date))
        when nil
          public_send(:"#{attr}=", nil)
        else
          return unless strict

          raise InvalidNepaliDateError,
                "Expected Miti::NepaliDate, String, or nil, got #{value.class}"
        end
      end
    end
  end
end
