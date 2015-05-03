class CreateColumnDiffs < ActiveRecord::Migration
  def change
    create_table :column_diffs do |t|
      t.datetime :changed_at
      t.string   :model_name
      t.integer  :record_id
      t.string   :column_name
      t.hstore   :value
    end

    add_index :column_diffs, :changed_at
    add_index :column_diffs, [:changed_at, :model_name]
    add_index :column_diffs, [:model_name, :record_id]
    add_index :column_diffs, [:changed_at, :model_name, :record_id]
  end
end
