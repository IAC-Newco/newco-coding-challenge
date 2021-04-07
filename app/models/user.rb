class User < ApplicationRecord
  include TokenGenerator

  has_many :follower_relationships, class_name:  "Follow",
                                   foreign_key: :following_id,
                                   dependent:   :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :following_relationships, class_name:  "Follow",
                                   foreign_key: :user_id,
                                   dependent:   :destroy
  has_many :following, through: :following_relationships, source: :following

  has_many :posts
  has_many :views
  has_many :likes

  before_create :generate_api_token

  private

  def generate_api_token
    self.api_token = generate_token(User, 'api_token')
  end

end
