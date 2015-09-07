class CreateTrackedChangesFunctionTriggersOnAuthors < ActiveRecord::Migration
  def up

    execute <<-SQL
      CREATE TRIGGER tracked_changes_function_on_authors_insert_trigger
      AFTER INSERT ON authors
      FOR EACH ROW
      EXECUTE PROCEDURE tracked_changes_function('Author');
    SQL

    execute <<-SQL
      CREATE TRIGGER tracked_changes_function_on_authors_update_trigger
      AFTER UPDATE ON authors
      FOR EACH ROW
      WHEN (OLD.* IS DISTINCT FROM NEW.*)
      EXECUTE PROCEDURE tracked_changes_function('Author');
    SQL

  end

  def down

    execute <<-SQL
      DROP TRIGGER tracked_changes_function_on_authors_insert_trigger ON authors;
    SQL

    execute <<-SQL
      DROP TRIGGER tracked_changes_function_on_authors_update_trigger ON authors;
    SQL

  end
end
