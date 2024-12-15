class CreateFoodPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :food_posts do |t|
      t.string :title
      t.text :description
      t.integer :quantity
      t.string :unit
      t.date :expiration_date
      t.string :pickup_location
      t.string :pickup_time_slot
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
