require 'rails_helper'

describe Category do
  it {should validate_presence_of(:name)}
  it {should validate_length_of(:name)}
  it {should validate_length_of(:description)}
  it {should validate_presence_of(:description)}

  it {should have_many(:questions)}
  it {should have_many(:user_categories)}
  it {should have_many(:users)}
end
