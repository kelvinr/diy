require 'rails_helper'

describe Message do

  it {should belong_to(:recipient)}
  it {should belong_to(:sender)}

  it {should validate_presence_of(:subject)}
  it {should validate_presence_of(:body)}

  describe 'mark_read!' do
    it "should update message to read status" do
      message = Fabricate(:message)
      message.mark_read!
      expect(message.read).to eq(true)
    end
  end
end
