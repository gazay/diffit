# encoding: utf-8

module Diffit
  module Utils
    # Converts the argument to a corresponding datetime
    #
    # @param [#to_datetime, #to_i] value
    #
    # @return [DateTime]
    #
    # @raise [ArgumentError] in case the argument cannot be converted to data
    #
    def self.timestamp(value)
      if value.respond_to?(:to_datetime)
        value.to_datetime
      elsif value.respond_to?(:to_i)
        Time.at(value.to_i).to_datetime
      else
        raise ArgumentError, "#{value.inspect} is not a timestamp!"
      end
    end
  end
end
