class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :title
      t.text :body
      t.text :tags, array: true, default: []
      t.belongs_to :author
    end
  end
end
