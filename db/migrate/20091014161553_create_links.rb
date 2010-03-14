class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :source_url_id
      t.integer :post_id
      t.string :url
      t.string :status, :default => "uncrawwwled"
      t.string :original_image_path, :default => "/images/missing.png"
      t.text :description
      t.text :images
      
      # paperclip      
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
