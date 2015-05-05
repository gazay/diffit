function_name = "#{table_name}_#{column_name}"
%Q|
CREATE FUNCTION diff_#{function_name}_fun(record_id int, _value hstore)
BEGIN
  DELETE FROM column_diffs
  WHERE table_name = #{table_name} AND column_name = #{column_name} AND record_id = #{record_id};
  INSERT INTO column_diffs (record_id, table_name, column_name, value)
  VALUES (record_id, #{table_name}, #{column_name}, _value);
END;

CREATE TRIGGER diff_#{function_name}_trigger
  AFTER UPDATE OR CREATE OR DELETE OF #{column_name} ON #{table_name}
  FOR EACH ROW
  WHEN (OLD.#{column_name} IS DISTINCT FROM NEW.#{column_name})
  EXECUTE PROCEDURE diff_#{function_name}_fun();
  |
