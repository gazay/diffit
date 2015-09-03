# encoding: utf-8

module Diffit

  class Query

    # Builds list of all changes
    #
    # @api private
    #
    class All < Query

      # @private
      def initialize
        super(nil)
      end

      private

      def query(timestamp)
        table
          .where(table[:changed_at].gteq(timestamp))
          .order(:table_name, :record_id)
          .project(table[:table_name], table[:record_id], table[:column_name], table[:value], table[:changed_at])
      end

    end # class Join

  end # class Query

end # module Diffit
