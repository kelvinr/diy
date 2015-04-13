Fabricator(:question) do
  title { Faker::Lorem.words(3).join(" ") }
  body { Faker::Lorem.paragraph }
  user_id { (1..40).to_a.sample }
end
