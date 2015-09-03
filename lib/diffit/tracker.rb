module Diffit
  class Tracker

    attr_reader :timestamp

    delegate :to_h, :to_hash, :to_json, :each, :length, :size, to: :changes

    # Instantiates a Diffit::Tracker with provided timestamp.
    #
    # @param timestamp [Time, DateTime, Date, Fixnum] date, time or timestamp.
    # @return [Diffit::Tracker] Diffit::Tracker
    def initialize(timestamp)
      @timestamp = Timestamp.new(timestamp)
      @tracked = []
      @changes = Diffit::Changes.new(self.timestamp)
      @fetched = false
    end

    def initialize_clone(_other)
      @tracked = Array.new(@tracked)
      @changes = Diffit::Changes.new(timestamp)
    end

    # Appends provided objects.
    #
    # @param object [ActiveRecord::Relation, ActiveRecord::Base, Array(ActiveRecord::Base), Array(ActiveRecord::Relation)]
    # @return [Diffit::Tracker] new instance of Diffit::Tracker.
    def append(*objects)
      copy = clone
      copy.append!(*objects)
      copy
    end

    # Appends provided objects to `self`.
    #
    # @param object [ActiveRecord::Relation, ActiveRecord::Base, Array(ActiveRecord::Base), Array(ActiveRecord::Relation)]
    # @return [self] self
    def append!(*objects)
      @tracked += objects.flatten.map(&Query.method(:build))
      @changes.cleanup!
      @fetched = false

      self
    end

    # Appends all changes.
    #
    # @return [Diffit::Tracker] a new instance of Diffit::Tracker.
    def all
      copy = clone
      copy.all!

      copy
    end

    # Appends all changes to `self`.
    #
    # @return [self] self.
    def all!
      @changes.cleanup!
      Query::All
        .new
        .call(timestamp)
        .group_by { |row| row[:table_name] }
        .each { |t, records| @changes.append t.classify, records }

      self
    end

    # Populates changes from a list of tracked objects
    #
    # @return [Diffit::Changes]
    #
    def changes
      return @changes if @fetched
      @tracked.each { |item| @changes.append item.name, item.call(timestamp) }
      @fetched = true
      @changes.prepare!
      @changes
    end
  end
end
