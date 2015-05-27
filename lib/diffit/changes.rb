module Diffit
  class Changes

    include Enumerable

    attr_reader :timestamp
    attr_reader :records

    # Instantiates a Diffit::Changes with provided timestamp.
    #
    # @param timestamp [Time, DateTime, Date, Fixnum] date, time or timestamp.
    # @return [Diffit::Changes] Diffit::Changes
    def initialize(timestamp)
      @timestamp = timestamp
      @records = []
    end

    # Appends provided data to `self`.
    #
    # @param model [String] model name.
    # @param data [Array(Hash)] data to append.
    # @return [self] self
    def append(model, data)
      data.group_by { |row| row[:record_id] }.each do |record_id, changes|
        @records << Record.new(model, record_id, changes.map { |c| c.slice(:column_name, :value, :changed_at)})
      end
      @length = nil
      self
    end

    # Are there any changes?
    #
    # @return [Boolean] existence of changes.
    def empty?
      @records.empty?
    end

    # Number of changes.
    #
    # @return [Fixnum] number of changes
    def length
      @length ||= @records.inject(0) { |v,r| v += r.changes.length }
    end

    # Calls the given block once for each record in the collection.
    #
    # @return [Enumerator] if no block is given.
    # @return [Array(Diffit::Record)] otherwise
    def each
      if block_given?
        @records.each { |c| yield c }
      else
        @records.enum_for(:each)
      end
    end

    # A short `String` representation of `self`.
    #
    # @return [String] the object converted to string.
    def to_s
      sprintf '#<%s:%#0x @timestamp: %s @changes: {%d}>',
        self.class.to_s,
        self.object_id,
        @timestamp.strftime('%d/%b/%Y:%H:%M:%S %z'),
        length
    end

    alias :to_str :to_s

    # A `Hash` representation of `self`.
    #
    # @return [Hash] the object converted to hash.
    def to_h
      {timestamp: timestamp.to_i, changes: @records.map(&:to_h)}
    end

    alias :to_hash :to_h

    # A JSON representation of `self`.
    #
    # @return [String] the object converted to JSON.
    def to_json
      to_h.to_json
    end

    def prepare!
      @records.sort_by! { |record| record.last_changed_at }
      @records.uniq! { |record| [record.model, record.record_id] }
      nil
    end

    def cleanup!
      @records.clear
      @length = nil
    end

  end
end
