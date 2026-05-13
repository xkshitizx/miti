# frozen_string_literal: true

module Miti
  module Rails
    module FormHelper
      MONTH_OPTIONS = (1..12).map do |m|
        english = Miti::NepaliDate::MONTHS_IN_ENGLISH[m - 1]
        nepali  = Miti::NepaliDate::MONTHS_IN_NEPALI[m - 1]
        ["#{english} (#{nepali})", m]
      end.freeze

      def nepali_date_field(object_name, method, options = {})
        object = options.delete(:object) || instance_variable_get(:"@#{object_name}")
        value  = bs_value_for(object, method)

        tag_options = options.reverse_merge(
          type: "text",
          autocomplete: "off",
          placeholder: "YYYY-MM-DD",
          class: "miti-date-field",
          data: {
            controller: "miti-date-picker",
            "miti-date-picker-value-value": value&.to_s,
            action: "focus->miti-date-picker#open blur->miti-date-picker#blur keydown->miti-date-picker#keydown"
          }
        )
        tag_options[:value] = value&.to_s unless tag_options.key?(:value)

        ActionView::Helpers::Tags::TextField.new(object_name, method, self, tag_options).render
      end

      def nepali_date_select(object_name, method, options = {})
        object = options.delete(:object) || instance_variable_get(:"@#{object_name}")
        value  = bs_value_for(object, method)

        selected_year  = value&.barsa
        selected_month = value&.mahina
        selected_day   = value&.gatey

        order  = options.delete(:order) || %i[year month day]
        prompt = options.delete(:prompt) || false
        prefix = "#{object_name}_#{method}"

        tags = order.map do |part|
          case part
          when :year
            select_options = (1975..2100).map { |y| [y.to_s, y] }
            select_tag("#{prefix}(1i)", options_for_select(select_options, selected_year),
                       prompt: prompt, class: "miti-date-select__year")
          when :month
            select_tag("#{prefix}(2i)", options_for_select(MONTH_OPTIONS, selected_month),
                       prompt: prompt, class: "miti-date-select__month")
          when :day
            day_options = (1..31).map { |d| [d.to_s.rjust(2, "0"), d] }
            select_tag("#{prefix}(3i)", options_for_select(day_options, selected_day),
                       prompt: prompt, class: "miti-date-select__day")
          end
        end

        safe_join([hidden_field_tag("#{object_name}[#{method}]", "", id: "#{prefix}_hidden")] + tags, " ")
      end

      private

      def bs_value_for(object, method)
        return nil unless object&.respond_to?(method)

        ad_date = object.public_send(method)
        return nil unless ad_date

        case ad_date
        when Date, Time, DateTime
          Miti.to_bs(ad_date)
        when Miti::NepaliDate
          ad_date
        when String
          Miti.to_bs(Date.parse(ad_date))
        end
      rescue StandardError
        nil
      end
    end
  end
end

module ActionView
  module Helpers
    class FormBuilder
      def nepali_date_field(method, options = {})
        @template.nepali_date_field(@object_name, method, options.merge(object: @object))
      end

      def nepali_date_select(method, options = {})
        @template.nepali_date_select(@object_name, method, options.merge(object: @object))
      end
    end
  end
end
