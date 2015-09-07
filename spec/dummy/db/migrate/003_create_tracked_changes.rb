class CreateTrackedChanges < ActiveRecord::Migration
  def up
    create_table :tracked_changes do |t|
      t.references :diffable, polymorphic: true
      t.string :column_name
      t.json :value
      t.timestamp :changed_at
    end

    add_index :tracked_changes, :diffable_type
    add_index :tracked_changes, :diffable_id
    add_index :tracked_changes, :changed_at

    execute <<-SQL
      ALTER TABLE tracked_changes
      ADD CONSTRAINT record_identifiers UNIQUE (diffable_type, diffable_id, column_name);
    SQL
  end

  def down
    drop_table :tracked_changes
  end
end
