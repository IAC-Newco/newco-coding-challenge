require "rails_helper"

RSpec.describe Follow, type: :model do

  describe "Associations" do
    it { should belong_to(:follower) }
    it { should belong_to(:following) }
  end

end
