require 'generators/diffit/base_generator'

module Diffit
  class StructureGenerator < Diffit::BaseGenerator

    source_root File.dirname(__FILE__)

    desc 'Creates migrations for tracking table and stored procedure.'

    def create_table_migration
      basename = "create_#{Diffit.table_name.to_s.underscore}"
      create_diffit_migration 'migrations/create_table.erb', basename
    end

    def create_function_migration
      basename = "create_#{Diffit.function_name.to_s.underscore}"
      create_diffit_migration 'migrations/create_function.erb', basename
    end

  end
end
