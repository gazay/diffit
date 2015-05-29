class CreateTrackedChangesFunctionTriggersOnPosts < ActiveRecord::Migration
  def up

    execute <<-SQL
      CREATE TRIGGER tracked_changes_function_on_posts_insert_trigger
      AFTER INSERT ON posts
      FOR EACH ROW
      EXECUTE PROCEDURE tracked_changes_function();
    SQL

    execute <<-SQL
      CREATE TRIGGER tracked_changes_function_on_posts_update_trigger
      AFTER UPDATE ON posts
      FOR EACH ROW
      WHEN (OLD.* IS DISTINCT FROM NEW.*)
      EXECUTE PROCEDURE tracked_changes_function();
    SQL

  end

  def down

    execute <<-SQL
      DROP TRIGGER tracked_changes_function_on_posts_insert_trigger ON posts;
    SQL

    execute <<-SQL
      DROP TRIGGER tracked_changes_function_on_posts_update_trigger ON posts;
    SQL

  end
end
