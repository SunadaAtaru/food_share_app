require 'rails_helper'

# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(username: "testuser", email: "test@example.com", password: "password")
    expect(user).to be_valid
  end

  it "is not valid without a username" do
    user = User.new(username: nil, email: "test@example.com", password: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = User.new(username: "testuser", email: nil, password: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without a unique username" do
    User.create(username: "testuser", email: "test1@example.com", password: "password")
    user = User.new(username: "testuser", email: "test2@example.com", password: "password")
    expect(user).to_not be_valid
  end
end

