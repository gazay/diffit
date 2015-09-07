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
          .where(table[:diffable_type].eq(name))
          .where(table[:diffable_id].eq(id))
          .order(:diffable_type, :diffable_id)
          .project(table[:diffable_id], table[:column_name], table[:value], table[:changed_at])
      end

      def id
        object.id
      end

    end # class Record

  end # class Query

end # module Diffit
