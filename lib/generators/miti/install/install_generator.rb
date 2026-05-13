# frozen_string_literal: true

module Miti
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Installs Miti Rails integration: importmap pins, Stimulus controller, and stylesheets"

      def pin_importmap
        if File.exist?("config/importmap.rb")
          append_to_file "config/importmap.rb" do
            "\n# Miti: Nepali date picker\npin " \
            "\"miti/date_picker_controller\", to: \"miti/date_picker_controller.js\"\n"
          end
        else
          say "Skipping importmap: config/importmap.rb not found", :yellow
        end
      end

      def register_stimulus_controller
        controller_path = "app/javascript/controllers/index.js"

        if File.exist?(controller_path)
          append_to_file controller_path do
            "\nimport MitiDatePickerController from \"miti/date_picker_controller\"\n" \
            "application.register(\"miti-date-picker\", MitiDatePickerController)\n"
          end
        else
          say "Skipping Stimulus registration: #{controller_path} not found", :yellow
        end
      end

      def add_stylesheet
        css_file = detect_css_file
        return unless css_file

        append_to_file css_file do
          "\n/* Miti: Nepali calendar and date picker styles */\n" \
          " *= require miti/calendar\n"
        end
      end

      def add_date_picker_data_to_layout
        layout = detect_layout
        return unless layout

        inject_into_file layout, before: "</head>" do
          "\n  <%= include_miti_date_picker_data %>\n"
        end
      end

      private

      def detect_css_file
        %w[
          app/assets/stylesheets/application.css
          app/assets/stylesheets/application.css.scss
          app/assets/stylesheets/application.bootstrap.css
        ].detect { |f| File.exist?(f) }
      end

      def detect_layout
        %w[
          app/views/layouts/application.html.erb
          app/views/layouts/application.html.haml
          app/views/layouts/application.html.slim
        ].detect { |f| File.exist?(f) }
      end
    end
  end
end
