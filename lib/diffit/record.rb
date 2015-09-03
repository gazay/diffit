module Diffit
  # Describes the record of object's changes
  class Record

    # @!attribute [r] model
    # @return [Class] the class of the object that has been changed
    attr_reader :model

    # @!attribute [r] record
    # @return [Integer] the id of the object that has been changed
    attr_reader :record_id

    # @!attribute [r] changes
    # @return [Array<Hash>] the list of changes of the object
    attr_reader :changes

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
