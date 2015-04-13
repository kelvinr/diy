require 'rails_helper'

describe User do
  let(:user) { Fabricate(:user, verified: false) }
  let(:obj) { S3_BUCKET.put_object(key: "uploads/#{SecureRandom.uuid}",
                                  acl: "public-read-write")}

  it {should validate_presence_of(:email)}
  it {should validate_uniqueness_of(:email).case_insensitive}
  it {should validate_length_of(:email)}
  it {should allow_value("foobar090@hotmail.com").for(:email)}
  it {should have_secure_password}
  it {should validate_length_of(:password)}
  it {should validate_presence_of(:username)}

  it {should have_many(:comments)}
  it {should have_many(:questions)}
  it {should have_many(:user_categories)}
  it {should have_many(:subs)}
  it {should have_many(:recieved_messages)}
  it {should have_many(:sent_messages)}
  it {should have_many(:unread_messages)}

  describe "digest" do
    it "creates a one-way hash" do
      string = User.digest("astringdigest")
      expect(BCrypt::Password.new(string).is_password?("astringdigest")).to eq(true)
    end
  end

  describe "new_token" do
    it "returns a urlsafe_base64 token" do
      string = User.new_token
      expect(string).to match(/\S/)
    end
  end

  describe '#remember' do
    before { user.remember }

    it 'sets a remember token' do
      expect(user.remember_token).not_to be_nil
    end

    it 'sets the users remember digest' do
      expect(BCrypt::Password.new(user.remember_digest).is_password?(user.remember_token)).to eq(true)
    end
  end

  describe '#forget' do
    before { user.remember }

    it 'sets users remember digest to nil' do
      user.forget
      expect(user.remember_digest).to be_nil
    end

    it 'sets  @current_user to nil' do
      user.forget
      expect(@current_user).to be_nil
    end
  end

  describe '#authenticated?' do
    it "returns true if users digest matchs token hash" do
      user.remember
      expect(user.authenticated?('remember', user.remember_token)).to eq(true)
    end

    it "returns false if digest is nil" do
      expect(user.authenticated?('reset', user.reset_token)).to eq(false)
    end
  end

  describe '#verify' do
    before { user.verify }

    it "sets user verified attribute to true" do
      expect(user.verified).to eq(true)
    end

    it "sets verification time" do
      expect(user.verified_at).not_to be_nil
    end
  end

  describe '#create_reset_digest' do
    before { user.create_reset_digest }

    it "sets users reset_token" do
      expect(user.reset_token).to match(/\S/)
    end

    it "sets the user reset_digest from hash of reset_token" do
      expect(BCrypt::Password.new(user.reset_digest).is_password?(user.reset_token)).to eq(true)
    end

    it "sets the users reset_sent_at" do
      expect(user.reset_sent_at).not_to be_nil
    end
  end

  context "Email delivery" do
    after(:each) { ActionMailer::Base.deliveries.clear }

    describe '#send_verification_email' do
      it "sends verification email" do
        user.send_verification_email
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end

    context "Password reset" do
      before(:each) do
        user.create_reset_digest
        user.send_password_reset_email
      end

      describe '#send_password_reset_email' do
        it "sends email with link to reset password" do
          expect(ActionMailer::Base.deliveries.size).to eq(1)
        end
      end

      describe '#password_reset_expired?' do
        it "returns false if reset sent less than 2 hours ago" do
          expect(user.password_reset_expired?).to eq(false)
        end

        it "returns true if reset sent more than 2 hours ago" do
          user.reset_sent_at = 3.hours.ago
          expect(user.password_reset_expired?).to eq(true)
        end
      end
    end
  end

  describe '#mark_unread_messages!' do
    it 'changes unread messages to read' do
      user.unread_messages << Fabricate.times(2, :message, sender_id: user.id)
      user.mark_unread_messages!
      expect(user.unread_messages.size).to eq(0)
    end
  end

  describe '#delete_avatar' do
    it "no action when no key is found or it's avatar-placeholder" do
      expect(user.delete_avatar).to be_nil
    end

    context "Avatar key present" do
      before(:each) do
        obj
        user.avatar_url = "#{S3_BUCKET.url}/#{obj.key}"
      end

      it "searches bucket for given key" do
        expect(user.delete_avatar.class).to eq(Aws::PageableResponse)
      end

      it "deletes object if it exists" do
        user.delete_avatar
        expect(S3_BUCKET.object(user.avatar_url).exists?).to eq(false)
      end
    end
  end

  describe '#set_avatar' do
    it "sets user avatar when avatar_url is blank" do
      bob = Fabricate.build(:user, avatar_url: nil)
      expect(bob.set_avatar).to eq("https://s3.amazonaws.com/diyavatar/avatar-placeholder.png")
    end

    it "doesn't change avatar_url if one is present" do
      bob = Fabricate(:user, avatar_url: "#{S3_BUCKET.url}/#{obj}")
      expect(bob.set_avatar).to be_nil
    end
  end

  describe '#set_default_subs' do
    it "sets default subs on user creation" do
      categories = Fabricate.times(3, :category)
      expect(user.subs).to eq(Category.where(id: [1, 2, 3]))
    end
  end

  describe '#create_verification_digest' do
    it 'sets verification_token on user creation' do
      expect(user.verification_token).to match(/\S/)
    end

    it 'sets the user verification_digest' do
      expect(BCrypt::Password.new(user.verification_digest).is_password?(user.verification_token)).to eq(true)
    end
  end
end
