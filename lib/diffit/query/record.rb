# encoding: utf-8

module Diffit

  class Query

    # Builds list of changes for AR::Base object
    #
    # @api private
    #
    class Record < Query

      def name
        object.model_name.name
      end

      private

      def query(timestamp)
        table
          .where(table[:changed_at].gteq(timestamp))
          .where(table[:table_name].eq(table_name))
          .where(table[:record_id].eq(id))
          .order(:table_name, :record_id)
          .project(table[:record_id], table[:column_name], table[:value], table[:changed_at])
      end

      def table_name
        object.class.table_name
      end

      def id
        object.id
      end

    end # class Record

  end # class Query

end # module Diffit
