Fabricator(:user) do
  username {  Faker::Internet.user_name }
  email { Faker::Internet.email }
  password { Faker::Internet.password }
  verified { true }
end
