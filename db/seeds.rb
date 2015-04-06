# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

a = ['Programming', 'Ruby', 'Python', 'Cars', 'Music', 'Gardening', 'Makeup', 'Home', 'Repair', 'Dogs', 'Cats',
  'Fish', 'Reptiles', 'Economics', 'Cooking', 'Resale', 'CSS', 'JavaScript', 'Photography', 'Video']

lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum convallis quis leo quis condimentum.
Nulla sit amet urna sit amet massa scelerisque molestie. Morbi faucibus nisi pharetra enim porttitor, et pretium purus eleifend. Proin est mi,
malesuada id consequat sodales, consequat id enim. Aenean aliquam massa ac ultrices volutpat. Morbi vel volutpat turpis. Donec fringilla tellus nisl,
vitae venenatis mi dapibus vitae."


x = 0

30.times do |x|
  x += 1
  User.create(username: "bob#{x}",
              email: "example#{x}@here.com",
              password: 'hunter',
              password_confirmation: 'hunter',
              verified: true)
end

a.each do |n|
  Category.create(name: n, description: lorem)
end


u = (1..30).to_a

7.times do
  Category.all.each do |c|
    Question.create(title: "I have a question about #{c.name}",
    body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum convallis quis leo quis condimentum.
    Nulla sit amet urna sit amet massa scelerisque molestie. Morbi faucibus nisi pharetra enim porttitor #{c.name}.",
    user_id: u.sample,
    category_id: c.id)
  end
end

16.times do
  Question.all.each do |q|
    Comment.create(body: "Aenean aliquam massa ac ultrices volutpat. Morbi vel volutpat turpis. Donec fringilla tellus nisl,
    vitae venenatis mi dapibus vitae.",
    user_id: u.sample,
    question_id: q.id)
  end
end
