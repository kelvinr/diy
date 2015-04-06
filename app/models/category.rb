class Category < ActiveRecord::Base
  include Searchable
  PER_PAGE = 10

  validates :name, presence: true, length: {minimum: 3}
  validates :description, presence: true, length: {minimum: 5}

  has_many :questions
  has_many :user_categories
  has_many :users, through: :user_categories
end
