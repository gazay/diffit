# encoding: utf-8

module Diffit

  class Query

    # Builds list of changes for the relation object
    # in case of :subquery strategy
    #
    # @api private
    #
    class SubqueryRelation < Query

      def initialize(_)
        super
        @sanitized =
          object.except(:select, :order, :group, :having, :includes).select(:id)
      end

      private

      def query(timestamp)
        query =
          table
          .where(table[:changed_at].gteq(timestamp))
          .where(table[:table_name].eq(object.table_name))
          .order(:table_name, :record_id)

        if joins_present?
          query = query.where(table[:record_id].in(Arel.sql(sanitized.to_sql)))
        end

        query.project(table[:record_id], table[:column_name], table[:value], table[:changed_at])
      end

      def joins_present?
        @sanitized.where_values.present? || @sanitized.joins_values.present?
      end

    end # class SubqueryRelation

  end # class Query

end # module Diffit
