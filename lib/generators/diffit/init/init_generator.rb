require 'generators/diffit/base_generator'

module Diffit
  class InitGenerator < Diffit::BaseGenerator

    source_root File.dirname(__FILE__)

    desc 'Creates a diffit initializer and migrations for tracking table and stored procedure.'

    argument :table_name, type: :string, required: true, desc: "Name of tracking table"

    def prepare
      Diffit.table_name = self.table_name
      Diffit.function_name = "#{self.table_name}_function"
    end

    def create_initializer
      template 'templates/diffit.erb', 'config/initializers/diffit.rb'
    end

    def create_table_migration
      basename = "create_#{Diffit.table_name.to_s.underscore}"
      create_diffit_migration 'migrations/create_table.erb', basename
    end

    def create_function_migration
      basename = "create_#{Diffit.table_name.to_s.underscore}_function"
      create_diffit_migration 'migrations/create_function.erb', basename
    end

  end
end
