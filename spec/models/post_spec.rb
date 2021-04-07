require "rails_helper"

RSpec.describe Post, type: :model do

  describe "Associations" do
    it { should have_many(:views) }
    it { should have_many(:likes) }
    it { should belong_to(:user) }
  end

  describe "Validations" do
    it { should validate_presence_of(:content) }
  end

end
