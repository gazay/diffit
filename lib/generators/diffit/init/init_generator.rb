require 'generators/diffit/base_generator'

module Diffit
  class InitGenerator < Diffit::BaseGenerator

    source_root File.dirname(__FILE__)

    desc 'Creates a diffit initializer.'

    def create_initializer
      template 'templates/diffit.rb', 'config/initializers/diffit.rb'
      notice 'Please check initializer for a list of available options.'
    end

  end
end
