# frozen_string_literal: true

module Miti
  module Rails
    module StoreBs
      extend ActiveSupport::Concern

      module ClassMethods
        def define_store_bs(attr)
          before_save do
            ad_date = public_send(attr)
            bs_value = Miti.to_bs(ad_date) if ad_date
            next unless bs_value

            if respond_to?(:write_attribute)
              write_attribute(:"#{attr}_bs", bs_value.to_s)
            else
              instance_variable_set(:"@#{attr}_bs", bs_value.to_s)
            end
          rescue Miti::ConversionUnavailableError
            nil
          end
        end
      end
    end
  end
end
