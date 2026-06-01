# frozen_string_literal: true

module Miti
  module Generators
    class StoreBsGenerator < ::Rails::Generators::Base
      desc "Creates a migration to add a BS date string column"

      argument :model_name, type: :string, desc: "Model name (e.g. Event)"
      argument :attr_name, type: :string, desc: "Attribute name (e.g. happened_on)"

      def validate_arguments
        if model_name.blank?
          raise ArgumentError,
                "Missing model name. Usage: rails generate miti:store_bs Event happened_on"
        end
        return unless attr_name.blank?

        raise ArgumentError,
              "Missing attribute name. Usage: rails generate miti:store_bs Event happened_on"
      end

      def create_migration
        if behavior == :invoke
          migration_content = <<~RUBY
            # frozen_string_literal: true

            class AddBsColumnFor#{attr_name.camelize}To#{model_name.camelize.pluralize} < ActiveRecord::Migration
              def change
                add_column :#{model_name.underscore.pluralize}, :#{attr_name}_bs, :string
              end
            end
          RUBY

          table_name = model_name.underscore.pluralize
          timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
          filename = "#{timestamp}_add_bs_column_for_#{attr_name}_to_#{table_name}.rb"
          migration_path = "db/migrate/#{filename}"

          create_file migration_path, migration_content
          say "Created migration: #{migration_path}", :green
        else
          # Revoke: find and remove migration files matching the pattern
          table_name = model_name.underscore.pluralize
          pattern = "*_add_bs_column_for_#{attr_name}_to_#{table_name}.rb"
          Dir["db/migrate/#{pattern}"].each do |f|
            FileUtils.rm(f)
            say "Removed migration: #{f}", :green
          end
        end
      end

      def inject_model_concern
        model_path = "app/models/#{model_name.underscore}.rb"
        return unless File.exist?(model_path)

        if behavior == :invoke
          invoke_inject(model_path)
        else
          revoke_inject(model_path)
        end
      end

      private

      def invoke_inject(model_path)
        content = File.read(model_path)
        return if content.include?("include Miti::Rails::ModelConcern") &&
                  content.include?("has_nepali_date :#{attr_name}")

        snippet = if content.include?("include Miti::Rails::ModelConcern")
                    "  has_nepali_date :#{attr_name}, store_bs: true\n"
                  else
                    "  include Miti::Rails::ModelConcern\n  has_nepali_date :#{attr_name}, store_bs: true\n"
                  end

        inject_into_class model_path, model_name.camelize, snippet
        say "Injected Miti concern into #{model_path}", :green
      end

      def revoke_inject(model_path)
        lines = File.readlines(model_path)
        filtered = lines.grep_v(/^\s+has_nepali_date\s+#{Regexp.escape(":#{attr_name}")}/)
        has_other = filtered.any? { |l| l.match?(/^\s+has_nepali_date\s+:/) }
        filtered = filtered.grep_v(/^\s+include Miti::Rails::ModelConcern\s*$/) unless has_other
        File.write(model_path, filtered.join)
        say "Removed Miti concern from #{model_path}", :green
      end

      public

      def print_instructions
        return unless behavior == :invoke

        say "", :green
        say "Almost done! Here's what you need to do:", :green
        say "", :green
        say "  1. Run the migration:", :yellow
        say "       rails db:migrate", :cyan
        say "", :green
        say "  2. In your form, use the date picker:", :yellow
        say "       <%= form.nepali_date_field :#{attr_name} %>", :cyan
        say "", :green
        say "  3. In your controller, permit the params:", :yellow
        say "       params.require(:#{model_name.underscore})" \
            ".permit(:#{attr_name}, :#{attr_name}_bs)", :cyan
        say "", :green
        say "  The submitted BS string is auto-converted to AD via the custom type.", :green
      end
    end
  end
end
