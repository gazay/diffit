module Diffit
  module Trackable

    def changes_since(timestamp)
      Diffit::Tracker.new(timestamp).append(self)
    end

    alias :diff_from :changes_since

    def changes_since_midnight
      Diffit::Tracker.new(Time.now.beginning_of_day).append(self)
    end

    alias :diff_from_midnight :changes_since_midnight

  end
end
