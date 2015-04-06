class UserMailerPreview < ActionMailer::Preview

  def email_verification
    user = User.first
    user.verification_token = User.new_token
    UserMailer.email_verification(user)
  end

  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end
end
