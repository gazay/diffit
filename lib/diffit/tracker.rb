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
      objects.each do |object|
        if object.is_a?(Array)
          append!(*object)
        elsif accepts?(object)
          @tracked << object
        else
          raise ArgumentError, 'Expected ActiveRecord::Base or ActiveRecord::Relation'
        end
      end

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
      handle_all.group_by { |row| row[:table_name] }.each do |t, records|
        @changes.append t.classify, records
      end
      self
    end

    def changes
      return @changes if @fetched

      @tracked.each do |object|
        if record?(object)
          @changes.append object.model_name.name, handle_one(object)
        elsif relation?(object)
          model = object.respond_to?(:model) ? object.model : object.class
          changes = case Diffit.strategy
                    when :join     then handle_relation_with_join(object)
                    when :subquery then handle_relation_with_subquery(object)
                    end

          @changes.append model.name, changes
        end
      end

      @fetched = true
      @changes.prepare!
      @changes
    end

    private

    def accepts?(object)
      record?(object) || relation?(object)
    end

    def relation?(object)
      object.is_a?(ActiveRecord::Relation) || ActiveRecord::Base.descendants.include?(object)
    end

    def record?(object)
      object.is_a?(ActiveRecord::Base)
    end

    def handle_relation_with_subquery(relation)
      table = Arel::Table.new(Diffit.table_name)

      sanitized = relation.except(:select, :order, :group, :having, :includes).select(:id)

      query = table.
        where(table[:changed_at].gteq(self.timestamp)).
        where(table[:table_name].eq(relation.table_name)).
        order(:table_name, :record_id)

      if sanitized.where_values.present? || sanitized.joins_values.present?
        query = query.where(table[:record_id].in(Arel.sql(sanitized.to_sql)))
      end

      query = query.project(table[:record_id], table[:column_name], table[:value], table[:changed_at])

      execute_query(query)
    end

    def handle_relation_with_join(relation)
      table = Arel::Table.new(Diffit.table_name)

      sanitized = relation.except(:select, :order, :group, :having, :includes)

      query = sanitized.
        from(table).
        where(table[:changed_at].gteq(self.timestamp)).
        where(table[:table_name].eq(relation.table_name)).
        select(table[:record_id], table[:column_name], table[:value], table[:changed_at])

      if sanitized.where_values.present? || sanitized.joins_values.present?

        join_cond = Arel::Nodes::On.new(sanitized.arel_table[:id].eq(table[:record_id]))
        join_arel = Arel::Nodes::InnerJoin.new(sanitized.arel_table, join_cond)

        query = query.joins(join_arel)
      end

      execute_query(query)
    end

    def handle_one(record)
      table = Arel::Table.new(Diffit.table_name)

      query = table.
        where(table[:changed_at].gteq(self.timestamp)).
        where(table[:table_name].eq(record.class.table_name)).
        where(table[:record_id].eq(record.id)).
        order(:table_name, :record_id).
        project(table[:record_id], table[:column_name], table[:value], table[:changed_at])

      execute_query(query)
    end

    def handle_all
      table = Arel::Table.new(Diffit.table_name)

      query = table.
        where(table[:changed_at].gteq(self.timestamp)).
        order(:table_name, :record_id).
        project(table[:table_name], table[:record_id], table[:column_name], table[:value], table[:changed_at])

      execute_query(query)
    end

    # Executes raw SQL query.
    # Uses ActiveRecord::Result, performs typecasting.
    #
    # @param query [ActiveRecord::Relation, Arel::SelectManager]
    # @return [Array(Hash)] query result
    def execute_query(query)
      result  = ActiveRecord::Base.connection.select_all(query.to_sql)

      cols = result.columns.map { |c| c.to_sym }
      rows = result.cast_values

      rows.map do |row|
        hash, i, l = {}, 0, cols.length

        while i < l
          hash[cols[i]] = row[i]
          i += 1
        end

        hash
      end
    end

  end
end
