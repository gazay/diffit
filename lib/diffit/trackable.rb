module Diffit
  module Trackable

    def self.included(base)
      base.extend(self)
    end

    def changes_since(timestamp)
      Diffit::Tracker.new(timestamp).append(self)
    end

    alias :diff_from :changes_since

    def changes_since_midnight
      changes_since Time.now.beginning_of_day
    end

    alias :diff_from_midnight :changes_since_midnight

  end
end
