# frozen_string_literal: true

module Miti
  module Rails
    module ControllerConcern
      extend ActiveSupport::Concern

      class_methods do
        def auto_convert_bs_dates(*date_params)
          before_action(only: date_params) do
            date_params.each do |param|
              next unless params[param].present?

              params[param] = begin
                parse_date_param(params[param])
              rescue StandardError
                params[param]
              end
            end
          end
        end
      end

      def parse_date_param(date_param)
        return Date.current if date_param.blank?

        Miti.to_ad(date_param)
      rescue StandardError
        Date.current
      end
    end
  end
end
