# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
	# メインのサンプルユーザーを1人作成する
	User.create!(username:  "Example User",
				email: "example@mail.com",
				password:              "foobar",
				password_confirmation: "foobar",
				admin:     true,
				activated: true,#有効化ずみに
				activated_at: Time.zone.now) #追加
	
	# 追加のユーザーをまとめて生成する
	99.times do |n|
  username = Faker::Name.unique.name  # Fakerで一意の名前を生成
	email = "example-#{n+1}@email.com"
	password = "password"
	User.create!(username:  username,
				email: email,
				password:              password,
				password_confirmation: password,
				activated: true,                #全て有効化
				activated_at: Time.zone.now)    #タイムスタンプ付与
	end