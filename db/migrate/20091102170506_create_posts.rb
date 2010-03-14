class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :name
      t.string :thumbnail_dimension
      t.integer :total_links
      t.integer :columns
      t.string :link_order
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
