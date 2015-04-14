Fabricator(:vote) do
  voteable { Fabricate(:question) }
  creator { Fabricate(:user) }
  vote { true }
end
