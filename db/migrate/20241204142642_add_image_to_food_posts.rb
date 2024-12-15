class AddImageToFoodPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :food_posts, :image, :string
  end
end
