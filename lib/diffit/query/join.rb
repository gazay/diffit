# encoding: utf-8

module Diffit

  class Query

    # Builds list of changes for the relation object in case of :join strategy
    #
    # @api private
    #
    class Join < Query

      # @private
      def initialize(_)
        super
        @sanitized = object.except(:select, :order, :group, :having, :includes)
      end

      private

      def query(timestamp)
        query = @sanitized.
          from(table).
          where(table[:changed_at].gteq(timestamp)).
          where(table[:table_name].eq(object.table_name)).
          select(table[:record_id], table[:column_name], table[:value], table[:changed_at])
        return query unless joins_present?

        join_cond = Arel::Nodes::On.new(sanitized.arel_table[:id].eq(table[:record_id]))
        join_arel = Arel::Nodes::InnerJoin.new(sanitized.arel_table, join_cond)
        query.joins(join_arel)
      end

      def joins_present?
        @sanitized.where_values.present? || @sanitized.joins_values.present?
      end

    end # class Join

  end # class Query

end # module Diffit
