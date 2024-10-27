# FactoryBot.define do
#   factory :user do
#     username { "MyString" }
#     email { "MyString" }
#     password_digest { "MyString" }
#   end
# end
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    username { "ExampleUser" }
    email { "user@example.com" }  # 有効なメールアドレスを指定
    password { "password" }
    password_confirmation { "password" }
    activated { true }
    activated_at { Time.zone.now }
  end
end
