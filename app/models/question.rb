class Question < ActiveRecord::Base
  PER_PAGE = 6

  include Searchable
  include Voteable

  default_scope {order('created_at ASC')}

  belongs_to :category
  belongs_to :creator, foreign_key: :user_id, class_name: :User
  has_many :comments
  has_many :votes, as: :voteable

  validates :title, presence: true
  validates :body, presence: true
end
