require 'rails_helper'

describe Question do
  it {should validate_presence_of(:title)}
  it {should validate_presence_of(:body)}

  it {should belong_to(:category)}
  it {should belong_to(:creator)}
  it {should have_many(:comments)}
  it {should have_many(:votes)}
end
