require 'rails_helper'

describe Vote do
  let(:bob) { Fabricate(:user) }

  it {should belong_to(:voteable)}
  it {should belong_to(:creator).with_foreign_key('user_id').class_name('User')}

  describe '#vote_restriction' do
    it 'returns false when voter is not content creator' do
      vote = Fabricate(:vote, creator: bob)
      expect(vote.vote_restriction).to eq(false)
    end
  end
end
