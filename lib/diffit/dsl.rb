module Diffit
  module DSL

    def diffit
      include Diffit::Trackable
      extend Diffit::Trackable
    end

  end
end
