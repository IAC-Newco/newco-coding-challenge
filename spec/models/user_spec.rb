require "rails_helper"

RSpec.describe User, type: :model do

  describe "Associations" do
    it { should have_many(:follower_relationships).dependent(:destroy) }
    it { should have_many(:following_relationships).dependent(:destroy) }
    it { should have_many(:followers) }
    it { should have_many(:following) }
    it { should have_many(:posts) }
  end

  describe "before_create" do
    context "generate_api_token" do
      it "adds an api token to a user before creation" do
        user = FactoryBot.build(:user, api_token: nil)
        expect(user.api_token).to_not be
        user.save
        expect(user.api_token).to be
        expect(User.where(api_token: user.api_token).count).to eq(1)
      end
    end
  end

end
