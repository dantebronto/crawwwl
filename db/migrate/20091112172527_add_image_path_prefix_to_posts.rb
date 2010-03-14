class AddImagePathPrefixToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :image_path_prefix, :string, :default => ''
  end

  def self.down
    remove_column :posts, :image_path_prefix
  end
end
