require 'diffit/version'

module Diffit
  extend ActiveSupport::Autoload

  autoload :Timestamp
  autoload :Changes
  autoload :Record
  autoload :Tracker
  autoload :Trackable

  mattr_accessor :function_name
  @@function_name = :diffit_function

  mattr_accessor :table_name
  @@table_name = :diffit_column_diffs

  mattr_accessor :strategy
  @@strategy = :join

  def self.configure
    yield self
  end

end
