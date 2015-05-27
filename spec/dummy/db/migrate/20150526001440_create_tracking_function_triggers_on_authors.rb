class CreateTrackingFunctionTriggersOnAuthors < ActiveRecord::Migration
  def up

    execute <<-SQL
      CREATE TRIGGER tracking_function_on_authors_insert_trigger
      AFTER INSERT ON authors
      FOR EACH ROW
      EXECUTE PROCEDURE tracking_function();
    SQL

    execute <<-SQL
      CREATE TRIGGER tracking_function_on_authors_update_trigger
      AFTER UPDATE ON authors
      FOR EACH ROW
      WHEN (OLD.* IS DISTINCT FROM NEW.*)
      EXECUTE PROCEDURE tracking_function();
    SQL

  end

  def down

    execute <<-SQL
      DROP TRIGGER trigger_tracking_function_on_authors_insert_trigger ON authors;
    SQL

    execute <<-SQL
      DROP TRIGGER trigger_tracking_function_on_authors_update_trigger ON authors;
    SQL

  end
end
