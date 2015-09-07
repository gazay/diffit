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
          .order(:diffable_type, :diffable_id)
          .project(table[:diffable_type], table[:diffable_id], table[:column_name], table[:value], table[:changed_at])
      end

    end # class Join

  end # class Query

end # module Diffit
