# frozen_string_literal: true

module Miti
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Miti Rails integration: importmap pins, Stimulus controller, and stylesheets"

      class_option :copy_styles,
                   type: :boolean,
                   default: false,
                   desc: "Copy calendar.css into your app for easy customization (overrides gem default)"

      def pin_importmap
        return unless File.exist?("config/importmap.rb")

        content = <<~RUBY
          # Miti: Nepali date picker
          pin "miti/converter", to: "miti/converter.js"
          pin "miti/date_picker_controller", to: "miti/date_picker_controller.js"
        RUBY

        if behavior == :revoke
          gsub_file "config/importmap.rb", /\n?#{Regexp.escape(content)}/, ""
          return
        end

        return if file_contains?("config/importmap.rb", content.strip)

        append_to_file "config/importmap.rb", content
      end

      def register_stimulus_controller
        controller_path = "app/javascript/controllers/index.js"
        return unless File.exist?(controller_path)

        content = <<~JS
          import MitiDatePickerController from "miti/date_picker_controller"
          application.register("miti-date-picker", MitiDatePickerController)
        JS

        if behavior == :revoke
          gsub_file controller_path, /\n?#{Regexp.escape(content)}/, ""
          return
        end

        return if file_contains?(controller_path, content.strip)

        append_to_file controller_path, "\n#{content}"
      end

      def add_stylesheet
        css_path = "app/assets/stylesheets/miti/calendar.css"

        if options.copy_styles?
          if behavior == :revoke
            remove_file css_path if File.exist?(css_path)
          else
            create_file css_path, File.read(gem_css_path)
            say "Copied calendar.css to app/assets/stylesheets/miti/ — edit it directly to customize", :green
          end
        end

        css_file = detect_css_file
        return unless css_file

        return unless uses_sprockets?

        if behavior == :revoke
          gsub_file css_file, %r{\n \* \*= require miti/calendar}, ""
          return
        end

        return if file_contains?(css_file, "require miti/calendar")

        inject_into_file css_file, before: "\n */" do
          "\n * *= require miti/calendar"
        end
      end

      def add_helpers_to_layout
        layout = detect_layout
        return unless layout

        tags = "\n    <%= include_miti_date_picker_data %>"
        tags += "\n    <%= stylesheet_link_tag \"miti/calendar\" %>" unless uses_sprockets?

        if behavior == :revoke
          gsub_file layout, /\n\s*<%= include_miti_date_picker_data %>/, ""
          gsub_file layout, %r{\n\s*<%= stylesheet_link_tag "miti/calendar" %>}, ""
          return
        end

        return if file_contains?(layout, "include_miti_date_picker_data")

        inject_into_file layout, before: "</head>" do
          "#{tags}\n  "
        end
      end

      private

      def file_contains?(path, string)
        File.read(path).include?(string)
      end

      def gem_css_path
        File.expand_path("../../../../app/assets/stylesheets/miti/calendar.css", __dir__)
      end

      def uses_sprockets?
        File.exist?("Gemfile") && File.read("Gemfile").include?("sprockets-rails")
      end

      def detect_css_file
        return unless uses_sprockets?

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
