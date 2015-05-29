require 'rails/generators'
require 'rails/generators/active_record'

module Diffit
  class BaseGenerator < Rails::Generators::Base

    hide!

    include Rails::Generators::Migration

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    protected

    def migration_exists?(basename)
      self.class.migration_exists?('db/migrate', basename).present?
    end

    def create_diffit_migration(template, basename)
      if migration_exists?(basename)
        warning "Migration '#{basename}' already exists."
      else
        migration_template template, "db/migrate/#{basename}.rb"
        sleep 1
      end
    end

    def warning(message)
      say_status '!', message, :red
    end

  end
end
