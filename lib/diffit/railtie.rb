require 'rails/railtie'

module Diffit
  class Railtie < Rails::Railtie

    initializer "diffit.active_record.hook" do
      ActiveSupport.on_load(:active_record) do
        extend Diffit::DSL
      end
    end

  end
end
