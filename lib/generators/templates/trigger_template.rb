function_name = "#{table_name}_#{column_name}"
%Q|CREATE TRIGGER diff_#{function_name}_trigger
  AFTER UPDATE OR CREATE OR DELETE OF #{column_name} ON #{table_name}
  FOR EACH ROW
  WHEN (OLD.#{column_name} IS DISTINCT FROM NEW.#{column_name})
  EXECUTE PROCEDURE diff_#{function_name}_fun();
