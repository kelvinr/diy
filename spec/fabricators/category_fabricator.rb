Fabricator(:category) do
  name { Faker::Commerce.department(1) }
  description { Faker::Lorem.paragraph(2) }
end
