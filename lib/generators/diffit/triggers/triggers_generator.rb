require 'generators/diffit/base_generator'

module Diffit
  class TriggersGenerator < Diffit::BaseGenerator

    source_root File.dirname(__FILE__)

    argument :table_name, type: :string, required: true, desc: "ModelName or table_name"

    desc 'Creates diffit triggers using a ModelName or a table_name provided.'

    def create_triggers_migration
      detect_table_name!
      basename = "create_#{Diffit.function_name.to_s.underscore}_triggers_on_#{table_name}"
      create_diffit_migration 'migrations/create_triggers.erb', basename
    end

    protected

    def detect_table_name!
      return if table_name == table_name.tableize

      begin
        klass = table_name.classify.constantize
        self.table_name = klass.table_name if klass.respond_to?(:table_name)
      rescue NameError
      end

      nil
    end

  end
end
