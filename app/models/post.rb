class Post < ApplicationRecord

  belongs_to :user
  has_many :views
  has_many :likes

  validates :content, presence: true

end
