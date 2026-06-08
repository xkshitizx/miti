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

    initializer "miti.controller_concern" do
      ActiveSupport.on_load(:action_controller_base) do
        include Miti::Rails::ControllerConcern
      end
    end

    initializer "miti.routes" do |app|
      app.routes.prepend do
        post "miti/calendar_data", to: "miti/calendar_data#show"
      end
    end

    initializer "miti.importmap", after: :importmap do |app|
      if app.respond_to?(:importmap) && app.importmap.respond_to?(:draw)
        app.importmap.draw(root.join("config/importmap.rb"))
      end
    end

    initializer "miti.assets" do
      if defined?(Sprockets) && config.respond_to?(:assets)
        config.assets.precompile += %w[
          miti/calendar.css
          miti/converter.js
          miti/date_picker.js
          miti/date_picker_controller.js
          miti/index.js
        ]
      end
    end
  end
end
