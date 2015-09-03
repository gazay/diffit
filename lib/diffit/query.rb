# encoding: utf-8
module Diffit
  # Query object extracts array of object's changes from db
  #
  # This is an abstract class, implementing the strategy pattern. Its
  # subclasses describe queries for corresponding types of trackable objects.
  #
  # The class method [#build] choses a corresponding subclass depending
  # on the type of the object and current Diffit strategy for relations
  # (either `:join` or `:subquery`).
  #
  # @abstract
  #
  # @api private
  #
  class Query
    class << self
      # Builds a query for the object depending on its type and diffit strategy
      #
      # @param [Object] object
      #
      # @return [Diffit::Query]
      #
      # @raise [ArgumentError] if an object cannot be tracked
      #
      def build(object)
        return Query::Record.new(object) if record?(object)

        klass = (Diffit.strategy.equal?(:join) ? Join : Subquery)
        return klass.new(object) if relation?(object)

        fail ArgumentError, "#{object.inspect} is untrackable"
      end

      private

      def record?(object)
        object.is_a? ActiveRecord::Base
      end

      def relation?(object)
        object.is_a?(ActiveRecord::Relation) ||
          ActiveRecord::Base.descendants.include?(object)
      end
    end

    # @private
    def initialize(object)
      @object = object
      @table  = Arel::Table.new(Diffit.table_name)
    end

    # Returns the name for the <relation> object
    #
    # @return [String]
    #
    def name
      (object.respond_to?(:model) ? object.model : object.class).name
    end

    # Returns a list of object's changes for given timestamp
    #
    # @param [Diffit::Timestamp] timestamp
    #
    # @return [Array<Hash>]
    #
    def call(timestamp)
      sql  = query(timestamp).to_sql
      data = ActiveRecord::Base.connection.select_all(sql)
      cols = data.columns.map(&:to_sym)
      rows = data.cast_values

      rows.map { |row| Hash[cols.zip(row)] }
    end

    private

    attr_reader :object, :table, :sanitized
  end # class Query

  # Loads concrete subclasses of Query object
  require_relative 'query/record'
  require_relative 'query/subquery'
  require_relative 'query/join'
  require_relative 'query/all'
end # module Diffit
