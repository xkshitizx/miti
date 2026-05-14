# frozen_string_literal: true

module Miti
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Miti Rails integration: importmap/bundler JS, Stimulus controller, and stylesheets"

      class_option :copy_styles,
                   type: :boolean,
                   default: false,
                   desc: "Copy calendar.css into your app for easy customization (overrides gem default)"

      class_option :copy_javascript,
                   type: :boolean,
                   default: false,
                   desc: "Force copy JS files into app/javascript/miti/ for bundler setup"

      def pin_or_copy_javascript
        if importmap?
          pin_importmap
        else
          copy_javascript_files
          pin_importmap if File.exist?("config/importmap.rb")
        end
      end

      def register_stimulus_controller
        controller_path = "app/javascript/controllers/index.js"
        return unless File.exist?(controller_path)

        import_path = importmap? ? "miti/date_picker_controller" : "../miti/date_picker_controller"
        content = <<~JS
          import MitiDatePickerController from "#{import_path}"
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
            create_file css_path,
                        File.read(File.expand_path("../../../../app/assets/stylesheets/miti/calendar.css", __dir__))
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

        inject_into_file layout, before: %r{</head>}i do
          "#{tags}\n  "
        end
      end

      private

      def pin_importmap
        return unless File.exist?("config/importmap.rb")

        if behavior == :revoke
          gsub_file "config/importmap.rb", %r{\n# Miti: Nepali date picker\npin "miti/converter".*}, ""
          gsub_file "config/importmap.rb", %r{\npin "miti/date_picker_controller".*}, ""
          return
        end

        unless file_contains?("config/importmap.rb", 'pin "miti/converter"')
          append_to_file "config/importmap.rb", <<~RUBY
            # Miti: Nepali date picker
            pin "miti/converter", to: "miti/converter.js"
            pin "miti/date_picker_controller", to: "miti/date_picker_controller.js"
          RUBY
        end

        return if file_contains?("config/importmap.rb", '"@hotwired/stimulus"')

        append_to_file "config/importmap.rb",
                       "pin \"@hotwired/stimulus\", to: \"stimulus.min.js\"\n"
      end

      def copy_javascript_files
        js_dir = "app/javascript/miti"
        if behavior == :revoke
          remove_file "#{js_dir}/converter.js"
          remove_file "#{js_dir}/date_picker_controller.js"
          FileUtils.rmdir(js_dir) if File.directory?(js_dir)
          return
        end

        ensure_stimulus_package

        empty_directory js_dir
        create_file "#{js_dir}/converter.js", File.read(gem_asset_path("converter.js"))
        content = File.read(gem_asset_path("date_picker_controller.js"))
                      .gsub('"miti/converter"', '"./converter"')
        create_file "#{js_dir}/date_picker_controller.js", content
      end

      def importmap?
        !uses_bundler? && File.exist?("config/importmap.rb")
      end

      def uses_bundler?
        return true if options[:copy_javascript]
        return false unless File.exist?("package.json")

        pkg = JSON.parse(File.read("package.json"))
        scripts = pkg.fetch("scripts", {})
        scripts.values.any? { |s| esbuild?(s) || s.include?("webpack") || s.include?("rollup") || s.include?("vite") }
      rescue JSON::ParserError
        false
      end

      def esbuild?(script)
        script.include?("esbuild") || script.include?("build --js")
      end

      def ensure_stimulus_package
        return unless File.exist?("package.json")

        pkg = JSON.parse(File.read("package.json"))
        deps = pkg.fetch("dependencies", {})
        dev_deps = pkg.fetch("devDependencies", {})
        return if deps.key?("@hotwired/stimulus") || dev_deps.key?("@hotwired/stimulus")

        say "Adding @hotwired/stimulus JavaScript package...", :green
        run package_manager_add_command
      end

      def package_manager_add_command
        if File.exist?("yarn.lock")
          "yarn add @hotwired/stimulus"
        elsif File.exist?("pnpm-lock.yaml")
          "pnpm add @hotwired/stimulus"
        elsif File.exist?("bun.lockb")
          "bun add @hotwired/stimulus"
        else
          "npm install @hotwired/stimulus --no-audit --no-fund"
        end
      end

      def file_contains?(path, string)
        File.read(path).include?(string)
      end

      def gem_asset_path(filename)
        File.expand_path("../../../../app/assets/javascripts/miti/#{filename}", __dir__)
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
