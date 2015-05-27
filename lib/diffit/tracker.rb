module Diffit
  class Tracker

    attr_reader :timestamp
    attr_reader :changes

    # Instantiates a Diffit::Tracker with provided timestamp.
    #
    # @param timestamp [Time, DateTime, Date, Fixnum] date, time or timestamp.
    # @return [Diffit::Tracker] Diffit::Tracker
    def initialize(timestamp)
      if timestamp.respond_to?(:to_datetime)
        @timestamp = timestamp.to_datetime
      elsif timestamp.respond_to?(:to_i)
        @timestamp = Time.at(@timestamp.to_i).to_datetime
      else
        raise ArgumentError, "#{timestamp.inspect} is not a timestamp!"
      end

      @changes = Diffit::Changes.new(@timestamp)
    end

    delegate :to_h, :to_hash, :to_json, :each, :length, :size, to: :changes

    public

    # Collects changes for provided object.
    #
    # @param object [ActiveRecord::Relation, Array(ActiveRecord::Base), ActiveRecord::Base]
    # @return [self] self
    def append(object)

      if object.is_a?(ActiveRecord::Relation) ||
         ActiveRecord::Base.descendants.include?(object)

        append_relation(object)

      elsif object.respond_to?(:to_a) &&
            (records = object.to_a).all? { |record| record.is_a?(ActiveRecord::Base) }

        append_many(records)

      elsif object.is_a?(ActiveRecord::Base)

        append_one(object)

      else
        raise ArgumentError, 'Expected ActiveRecord::Base or ActiveRecord::Relation'
      end
      self
    end

    # Collects all changes.
    #
    # @return [self] self.
    def all
      @changes.cleanup!
      handle_all.group_by { |row| row[:table_name] }.each do |t, records|
        @changes.append t.classify, records
      end
      self
    end

    protected

    # Collects changes for provided record.
    #
    # @param record [ActiveRecord::Base].
    # @return [self] self.
    def append_one(record)
      @changes.append record.model_name.name, handle_one(record)
      @changes.prepare!
      self
    end

    # Collects changes for each record in provided collection.
    #
    # @param records [Array(ActiveRecord::Base)]
    # @return [self] self.
    def append_many(records)
      records.each { |record| @changes.append record.model_name.name, handle_one(record) }
      @changes.prepare!
      self
    end

    # Collects changes for each record mathching conditions of provided relation.
    #
    # @param relation [ActiveRecord::Relation].
    # @return [self] self.
    def append_relation(relation)
      klass = relation.respond_to?(:model) ? relation.model : relation
      @changes.append klass.model_name.name, handle_relation(relation)
      @changes.prepare!
      self
    end

    private

    def handle_relation(relation)
      table = Arel::Table.new(Diffit.table_name)

      sanitized = relation.except(:select, :order, :group, :having, :includes)

      query = sanitized.
        from(table).
        where(table[:changed_at].gteq(@timestamp)).
        where(table[:table_name].eq(relation.table_name)).
        select(table[:record_id], table[:column_name], table[:value], table[:changed_at])

      unless sanitized.where_values.blank? &&
             sanitized.joins_values.blank?

        join_cond = Arel::Nodes::On.new(sanitized.arel_table[:id].eq(table[:record_id]))
        join_arel = Arel::Nodes::InnerJoin.new(sanitized.arel_table, join_cond)

        query = query.joins(join_arel)
      end

      execute_query(query)
    end

    def handle_one(record)
      table = Arel::Table.new(Diffit.table_name)

      query = table.
        where(table[:changed_at].gteq(@timestamp)).
        where(table[:table_name].eq(record.class.table_name)).
        where(table[:record_id].eq(record.id)).
        order(:table_name, :record_id).
        project(table[:record_id], table[:column_name], table[:value], table[:changed_at])

      execute_query(query)
    end

    def handle_all
      table = Arel::Table.new(Diffit.table_name)

      query = table.
        where(table[:changed_at].gteq(@timestamp)).
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
