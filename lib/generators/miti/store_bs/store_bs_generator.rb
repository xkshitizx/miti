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
        migration_content = <<~RUBY
          # frozen_string_literal: true

          class AddBsColumnFor#{attr_name.camelize}To#{model_name.camelize.pluralize} < ActiveRecord::Migration[7.1]
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
      end
    end
  end
end
