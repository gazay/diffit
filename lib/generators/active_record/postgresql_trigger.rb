class DiffitCreateTriggerFor<%= table_name.camelize %> < ActiveRecord::Migration
  def up
    ActiveRecord.connection.execute(%Q|
CREATE FUNCTION diff_<%= function_name %>_fun
    |)

    ActiveRecord.connection.execute(%Q|
CREATE TRIGGER diff_<%= function_name %>_trigger
  AFTER UPDATE OR CREATE OR DELETE OF <%= column_name %> ON <%= table_name %>
  FOR EACH ROW
  WHEN (OLD.<%= column_name %> IS DISTINCT FROM NEW.<%= column_name %>)
  EXECUTE PROCEDURE diff_<%= function_name %>_fun();
    |)
  end

  def down
    ActiveRecord.connection.execute(%Q|
DROP FUNCTION diff_<%= function_name %>_fun;
DROP TRIGGER diff_<%= function_name %>_trigger;
    |)
  end
end
