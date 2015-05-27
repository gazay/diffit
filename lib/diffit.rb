require 'diffit/version'
require 'diffit/railtie'

module Diffit
  extend ActiveSupport::Autoload

  autoload :Changes
  autoload :Record
  autoload :Tracker
  autoload :Trackable
  autoload :DSL

  mattr_accessor :function_name
  @@function_name = :diffit_function

  mattr_accessor :table_name
  @@table_name = :diffit_column_diffs

  def self.configure
    yield self
  end

end
