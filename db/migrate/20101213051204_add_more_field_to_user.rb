class AddMoreFieldToUser < ActiveRecord::Migration
  
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :website, :string
    add_column :users, :bio, :text
    add_column :users, :bio_html, :text
    add_column :users, :display_name, :string
    add_column :users, :permalink, :string
#    add_column :users, :status, :string    
    add_column :users, :posts_count, :integer
    add_column :users, :last_seen_at, :datetime
#    add_column :users, :activated_at, :datetime
    
    add_index "users", "permalink", :name => "index_users_on_permalink"
    add_index "users", "posts_count", :name => "index_users_on_posts_count"
  end

  def self.down
       
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :website
    remove_column :users, :bio
    remove_column :users, :bio_html
    remove_column :users, :display_name
    remove_column :users, :permalink
#    remove_column :users, :status
    remove_column :users, :posts_count
    remove_column :users, :last_seen_at
#    remove_column :users, :activated_at
    
  end
end
