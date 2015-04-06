class Vote < ActiveRecord::Base
  belongs_to :creator, foreign_key: :user_id, class_name: :User
  belongs_to :voteable, polymorphic: true

  validates :creator, absence: true, if: :vote_restriction

  def vote_restriction
    self.creator == self.voteable.creator
  end
end
