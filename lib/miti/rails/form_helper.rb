# frozen_string_literal: true

module Miti
  module Rails
    module FormHelper
      DATE_PICKER_ACTIONS = "focus->miti-date-picker#open blur->miti-date-picker#blur keydown->miti-date-picker#keydown"

      def month_options
        @month_options ||= (1..12).map do |m|
          english = Miti::NepaliDate.months_in_english[m - 1]
          nepali  = Miti::NepaliDate.months[m - 1]
          ["#{english} (#{nepali})", m]
        end.freeze
      end

      def nepali_date_field(object_name, method, options = {})
        object = options.delete(:object) || (object_name.presence && instance_variable_get(:"@#{object_name}"))
        default_val = options.delete(:value)
        theme = normalize_theme(options.delete(:theme))
        value = default_val ? parse_bs_value(default_val) : bs_value_for(object, method)

        name_prefix = object_name.presence ? "#{object_name}[" : nil
        name_suffix = object_name.presence ? "]" : nil

        tag_options = {
          type: "text",
          autocomplete: "off",
          placeholder: "YYYY-MM-DD",
          readonly: true,
          class: "miti-date-field",
          value: value&.to_s,
          name: "#{name_prefix}#{method}#{name_suffix}",
          data: {
            action: DATE_PICKER_ACTIONS.html_safe
          }
        }.merge(options.except(:separator))

        input = ActionView::Helpers::Tags::TextField.new(object_name, method, self, tag_options).render
        wrapper_data = { controller: "miti-date-picker", "miti-date-picker-value-value": value&.to_s }
        wrapper_data[:"miti-theme"] = theme if theme
        tag.div(class: "miti-date-field-wrapper", data: wrapper_data) { input + calendar_icon("miti-date-picker") }
      end

      def nepali_date_range_field(object_name, start_method, end_method, options = {})
        object = options.delete(:object) || (object_name.presence && instance_variable_get(:"@#{object_name}"))
        theme = normalize_theme(options.delete(:theme))
        start_val = parse_range_value(options.delete(:start_value), object, start_method)
        end_val = parse_range_value(options.delete(:end_value), object, end_method)
        trigger_html = options.delete(:trigger_html) || {}

        tag.div(class: "miti-date-range-wrapper",
                data: range_wrapper_data(start_val, end_val, theme)) do
          range_hidden_input(object_name, start_method, start_val, "start") +
            range_hidden_input(object_name, end_method, end_val, "end") +
            range_trigger(start_val, end_val, trigger_html)
        end
      end

      def nepali_date_select(object_name, method, options = {})
        object = options.delete(:object) || (object_name.presence && instance_variable_get(:"@#{object_name}"))
        value  = bs_value_for(object, method)
        field_method = select_method_for(object, method)

        selected_year  = value&.barsa
        selected_month = value&.mahina
        selected_day   = value&.gatey

        order  = options.delete(:order) || %i[year month day]
        prompt = options.delete(:prompt) || false

        tags = order.map do |part|
          case part
          when :year
            select_options = (1975..2100).map { |y| [y.to_s, y] }
            select_tag("#{object_name}[#{field_method}(1i)]", options_for_select(select_options, selected_year),
                       prompt: prompt, class: "miti-date-select__year")
          when :month
            select_tag("#{object_name}[#{field_method}(2i)]", options_for_select(month_options, selected_month),
                       prompt: prompt, class: "miti-date-select__month")
          when :day
            day_options = (1..32).map { |d| [d.to_s.rjust(2, "0"), d] }
            select_tag("#{object_name}[#{field_method}(3i)]", options_for_select(day_options, selected_day),
                       prompt: prompt, class: "miti-date-select__day")
          end
        end

        safe_join(tags, " ")
      end

      private

      def bs_value_for(object, method)
        bs_method = "#{method}_bs"
        if object.respond_to?(bs_method)
          bs_date = object.public_send(bs_method)
          return convert_to_nepali(bs_date) if bs_date
        end

        return nil unless object.respond_to?(method)

        ad_date = object.public_send(method)
        return nil unless ad_date

        convert_to_nepali(ad_date)
      end

      def select_method_for(object, method)
        bs_method = :"#{method}_bs"
        return bs_method if object.respond_to?("#{method}_bs") || object.respond_to?("#{method}_bs=")

        method
      end

      def calendar_icon(controller = "miti-date-picker", field = nil)
        action = field ? "click->#{controller}#open#{field.capitalize}" : "click->#{controller}#open"
        tag.button(type: "button", class: "miti-date-field__icon", tabindex: "-1",
                   data: { action: action }) { calendar_icon_svg }
      end

      def calendar_icon_svg
        tag.svg xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewBox: "0 0 24 24", fill: "none",
                stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round" do
          tag.rect(x: "3", y: "4", width: "18", height: "18", rx: "2", ry: "2") +
            tag.line(x1: "16", y1: "2", x2: "16", y2: "6") +
            tag.line(x1: "8", y1: "2", x2: "8", y2: "6") +
            tag.line(x1: "3", y1: "10", x2: "21", y2: "10")
        end
      end

      def normalize_theme(value)
        value&.to_s&.tr("_", "-")
      end

      def parse_bs_value(value)
        convert_to_nepali(value)
      end

      def parse_range_value(default, object, method)
        default ? parse_bs_value(default) : bs_value_for(object, method)
      end

      def range_hidden_input(object_name, method, value, target)
        name = "#{object_name.presence}[#{method}]".delete_prefix("[")
        tag.input(type: "hidden",
                  name: name,
                  value: value&.to_s,
                  id: "#{object_name}_#{method}".delete_prefix("_"),
                  data: { "miti-range-target": target })
      end

      def range_trigger(start_val, end_val, trigger_html)
        display_text = [start_val&.to_s, end_val&.to_s].compact.reject(&:empty?)
        display_text = display_text.any? ? display_text.join(" — ") : nil

        opts = {
          type: "text", readonly: true, placeholder: "Select date range",
          class: "miti-date-range__display", value: display_text,
          data: { action: "focus->miti-date-range#open blur->miti-date-range#blur keydown->miti-date-range#keydown" }
        }.merge(trigger_html) { |k, old, new| k == :data ? old.deep_merge(new) : new }

        tag.div(class: "miti-date-range__trigger") do
          tag.input(**opts) + calendar_icon("miti-date-range")
        end
      end

      def range_wrapper_data(start_val, end_val, theme)
        data = {
          controller: "miti-date-range",
          "miti-date-range-start-value": start_val&.to_s,
          "miti-date-range-end-value": end_val&.to_s
        }
        data[:"miti-theme"] = theme if theme
        data
      end

      def convert_to_nepali(value)
        case value
        when Date, Time, DateTime
          Miti.to_bs(value)
        when Miti::NepaliDate
          value
        when String
          parts = value.split(%r{[-/]})
          if parts.length == 3
            Miti::NepaliDate.new(barsa: parts[0].to_i, mahina: parts[1].to_i, gatey: parts[2].to_i)
          else
            Miti.to_bs(Date.parse(value))
          end
        end
      rescue ArgumentError, Miti::ConversionUnavailableError,
             Miti::NepaliDate::FormatError, Miti::NepaliDate::DateRangeError
        nil
      end
    end
  end
end

module Miti
  module Rails
    module FormBuilderMethods
      def nepali_date_field(method, options = {})
        @template.nepali_date_field(@object_name, method, options.reverse_merge(object: @object))
      end

      def nepali_date_range_field(start_method, end_method, options = {})
        @template.nepali_date_range_field(@object_name, start_method, end_method,
                                          options.reverse_merge(object: @object))
      end

      def nepali_date_select(method, options = {})
        @template.nepali_date_select(@object_name, method, options.reverse_merge(object: @object))
      end
    end
  end
end

if defined?(ActionView::Helpers::FormBuilder)
  unless ActionView::Helpers::FormBuilder.included_modules.include?(Miti::Rails::FormBuilderMethods)
    ActionView::Helpers::FormBuilder.include(Miti::Rails::FormBuilderMethods)
  end
elsif defined?(ActiveSupport)
  ActiveSupport.on_load(:action_view) do
    unless ActionView::Helpers::FormBuilder.included_modules.include?(Miti::Rails::FormBuilderMethods)
      ActionView::Helpers::FormBuilder.include(Miti::Rails::FormBuilderMethods)
    end
  end
end
