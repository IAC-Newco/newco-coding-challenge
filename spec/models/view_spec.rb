require "rails_helper"

RSpec.describe View, type: :model do

  describe "Associations" do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

end
