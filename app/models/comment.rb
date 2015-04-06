class Comment < ActiveRecord::Base
  include Voteable
  PER_PAGE = 12

  default_scope {order ('created_at DESC')}

  belongs_to :creator, foreign_key: :user_id, class_name: :User
  belongs_to :question
  has_many :votes, as: :voteable

  validates :body, presence: true, length: {minimum: 5}
end
