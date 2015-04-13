# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

40.times do
  Fabricate(:user)
end

20.times do
  category = Fabricate(:category)
  (1..20).to_a.sample.times do
    question = Fabricate(:question, category_id: category.id)
    category.questions << question
  end
end
