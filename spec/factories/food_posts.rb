FactoryBot.define do
  factory :food_post do
    title { "MyString" }
    description { "MyText" }
    quantity { 1 }
    unit { "MyString" }
    expiration_date { "2024-12-03" }
    pickup_location { "MyString" }
    pickup_time_slot { "MyString" }
    status { "MyString" }
    user { nil }
  end
end
