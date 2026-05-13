# frozen_string_literal: true

require "rails/engine"

module Miti
  class Engine < ::Rails::Engine
    initializer "miti.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include Miti::Rails::CalendarHelper
        include Miti::Rails::FormHelper
        include Miti::Rails::DatePickerHelper
      end
    end

    initializer "miti.active_record" do
      ActiveSupport.on_load(:active_record) do
        include Miti::Rails::ModelConcern
      end
    end

    if respond_to?(:config) && config.respond_to?(:assets)
      initializer "miti.assets" do
        config.assets.precompile += %w[
          miti/calendar.css
          miti/converter.js
          miti/date_picker_controller.js
        ]
      end
    end
  end
end
