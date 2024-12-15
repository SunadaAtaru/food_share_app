class AddNullConstraintsToFoodPosts < ActiveRecord::Migration[6.1]
  def change
    change_column_null :food_posts, :title, false
    change_column_null :food_posts, :quantity, false
    change_column_null :food_posts, :unit, false
    change_column_null :food_posts, :expiration_date, false
    change_column_null :food_posts, :pickup_location, false
    change_column_null :food_posts, :status, false
    change_column_default :food_posts, :status, 'available'
  end
end


