module Diffit
  class Record

    attr_reader :model, :record_id, :changes

    def initialize(model, record_id, changes)
      @model     = model
      @record_id = record_id
      @changes   = changes
    end

    # Timestamp of the latest change.
    #
    # @return [Time] latest change timestamp.
    def last_changed_at
      @last_changed_at ||= @changes.map { |c| c[:changed_at] }.max
    end

    # A `Hash` representation of `self`.
    #
    # @return [Hash] the object converted to hash.
    def to_h
      {model: model, record_id: record_id, changes: changes}
    end

  end
end
