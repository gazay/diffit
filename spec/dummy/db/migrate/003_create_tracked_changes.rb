class CreateTrackedChanges < ActiveRecord::Migration
  def up
    create_table :tracked_changes do |t|
      t.string :table_name
      t.integer :record_id
      t.string :column_name
      t.json :value
      t.timestamp :changed_at
    end

    add_index :tracked_changes, :table_name
    add_index :tracked_changes, :record_id
    add_index :tracked_changes, :changed_at

    execute <<-SQL
      ALTER TABLE tracked_changes
      ADD CONSTRAINT record_identifiers UNIQUE (table_name, record_id, column_name);
    SQL
  end

  def down
    drop_table :tracked_changes
  end
end
