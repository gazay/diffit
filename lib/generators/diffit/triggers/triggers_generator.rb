require 'generators/diffit/base_generator'

module Diffit
  class TriggersGenerator < Diffit::BaseGenerator

    source_root File.dirname(__FILE__)

    argument :model_name, type: :string, required: true, desc: "ModelName or table_name"

    desc 'Creates diffit triggers using a ModelName or a table_name provided.'

    def create_triggers_migration
      detect_model!
      basename = "create_#{Diffit.function_name.to_s.underscore}_triggers_on_#{@model.table_name}"
      create_diffit_migration 'migrations/create_triggers.erb', basename
    end

    protected

    def detect_model!
      @model = model_name.classify.constantize # TODO: use class cache?
      raise unless @model.respond_to?(:table_name)
    end

  end
end
