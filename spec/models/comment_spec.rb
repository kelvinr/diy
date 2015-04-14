require 'rails_helper'

describe Comment do
  it {should belong_to(:creator)}
  it {should belong_to(:question)}
  it {should have_many(:votes)}

  it {should validate_presence_of(:body)}
  it {should validate_length_of(:body)}
end
