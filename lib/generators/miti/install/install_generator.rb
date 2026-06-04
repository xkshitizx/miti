# frozen_string_literal: true

module Miti
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Miti Rails integration"

      class_option :copy_styles,
                   type: :boolean,
                   default: false,
                   desc: "Copy calendar.css into your app for easy customization"

      class_option :copy_javascript,
                   type: :boolean,
                   default: false,
                   desc: "Copy JS files into app/javascript/miti/ for bundler setup"

      def add_import_to_application_js
        js_path = "app/javascript/application.js"
        return unless File.exist?(js_path)

        marker = "import \"controllers\""
        return unless File.read(js_path).include?(marker)

        if behavior == :revoke
          gsub_file js_path, /\nimport "miti"/, "", force: true
          return
        end

        return if File.read(js_path).include?("import \"miti\"")

        inject_into_file js_path, after: "#{marker}\n" do
          "import \"miti\"\n"
        end
        say "Added import \"miti\" to #{js_path}", :green
      end

      def add_stylesheet_to_layout
        layout_path = Dir.glob("app/views/layouts/application.html.{erb,haml}").first
        return unless layout_path

        content = '    <%= stylesheet_link_tag "miti/calendar" %>'

        if behavior == :revoke
          gsub_file layout_path, /\n?#{Regexp.escape(content)}/, "", force: true
          return
        end

        return if File.read(layout_path).include?("miti/calendar")

        if layout_path.end_with?(".erb")
          inject_into_file layout_path, before: "  </head>" do
            "\n#{content}\n"
          end
        elsif layout_path.end_with?(".haml")
          inject_into_file layout_path, before: "%head" do
            "= stylesheet_link_tag \"miti/calendar\"\n"
          end
        end
        say "Added stylesheet_link_tag \"miti/calendar\" to #{layout_path}", :green
      end

      def copy_assets
        if options.copy_styles?
          copy_css_to_app
        end
        if options.copy_javascript? || uses_bundler?
          copy_javascript_files
        end
      end

      private

      def copy_css_to_app
        css_source = File.expand_path("../../../../app/assets/stylesheets/miti/calendar.css", __dir__)
        css_path = "app/assets/stylesheets/miti/calendar.css"

        if behavior == :revoke
          FileUtils.rm_f(css_path)
          say "Removed #{css_path}", :green
        else
          create_file css_path, File.read(css_source)
          say "Copied calendar.css to app/assets/stylesheets/miti/", :green
        end
      end

      def copy_javascript_files
        js_dir = "app/javascript/miti"
        if behavior == :revoke
          %w[converter date_picker date_picker_controller index].each do |f|
            FileUtils.rm_f("#{js_dir}/#{f}.js")
          end
          FileUtils.rm_rf(js_dir) if File.directory?(js_dir)
          return
        end

        empty_directory js_dir
        %w[converter date_picker date_picker_controller].each do |f|
          write_js_file(js_dir, f)
        end
      end

      def write_js_file(js_dir, basename)
        content = File.read(gem_asset_path("#{basename}.js"))
                     .gsub('"miti/converter"', '"./converter"')
                     .gsub('"miti/date_picker"', '"./date_picker"')
        create_file "#{js_dir}/#{basename}.js", content
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

      def gem_asset_path(filename)
        File.expand_path("../../../../app/assets/javascripts/miti/#{filename}", __dir__)
      end
    end
  end
end
