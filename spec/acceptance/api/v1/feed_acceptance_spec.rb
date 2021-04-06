require "rails_helper"

resource "Feed" do
  explanation "Feed Resource"

  header "Content-Type", "application/json"

  get "/api/v1/feed/ordered_by_creation" do
    route_summary "Main Homepage Feed"
    route_description <<~DESCRIPTION
      Naive approach to a feed -> just ordered reverse chronologically of creation date
      DESCRIPTION

    before do
      5.times { FactoryBot.create :user }
    end

    let(:user) { FactoryBot.create(:user) }
    let(:api_token) { user.api_token }

    let!(:posts) do
      5.times do
        FactoryBot.create(:post, user: User.all.sample)
      end
    end

    let(:raw_post) do
      {
        api_token: api_token
      }
    end

    context "401 Unauthorized" do
      let(:api_token) { nil }
      example_request "Unauthenticated Request." do
        expect(status).to be_http_status(:forbidden)
        expect(response_json).to include_json({
          "title": I18n.t("error_messages.unauthenticated_request.title")
        })
      end
    end

    context "200 OK" do
      example_request "Fetches a simple feed sorted reverse chron" do
        expect(status).to be_http_status(:ok)
        expect(response_json.count).to eq(5)
        # Check that each post was created before the next post in the list
        response_json.each_with_index do |rj, index|
          next if index == 4 # do not look at last post
          expect(Post.find(rj['id']).created_at > Post.find(response_json[index+1]['id']).created_at).to eq(true)
        end
      end
    end
  end

  get "/api/v1/feed/for_user" do
    route_summary "Main Homepage Feed"
    route_description <<~DESCRIPTION
      Slightly less naive approach to a feed -> based on view status of a post and following status of the poster
      DESCRIPTION

    before do
      5.times { FactoryBot.create :user }
    end

    let(:user) { FactoryBot.create(:user) }
    let(:api_token) { user.api_token }

    let!(:followed_users) do
      5.times do
        followed_user = FactoryBot.create(:user)
        user.following << followed_user
      end
    end

    let!(:seventh_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      user.views.create(post: post)
      post
    end

    let!(:sixth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      user.views.create(post: post)
      post
    end

    let!(:first_place_post) do
      post = FactoryBot.create(:post, user: user.following.sample)
      post
    end

    let!(:second_place_post) do
      post = FactoryBot.create(:post, user: User.where.not(id: user.following.pluck(:id)).sample)
      post
    end

    let!(:third_place_post) do
      post = FactoryBot.create(:post, user: user.following.sample, created_at: 25.hours.ago)
      post
    end

    let!(:fourth_place_post) do
      post = FactoryBot.create(:post, user: User.where.not(id: user.following.pluck(:id)).sample, created_at: 25.hours.ago)
      post
    end

    let!(:fifth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      user.views.create(post: post)
      post
    end

    let(:raw_post) do
      {
        api_token: api_token
      }
    end

    context "401 Unauthorized" do
      let(:api_token) { nil }
      example_request "Unauthenticated Request." do
        expect(status).to be_http_status(:forbidden)
        expect(response_json).to include_json({
          "title": I18n.t("error_messages.unauthenticated_request.title")
        })
      end
    end

    context "200 OK" do
      example_request "Fetches a feed sorted by following status and viewed status" do
        expect(status).to be_http_status(:ok)
        expect(response_json.count).to eq(7)
        expect(response_json[0]['id']).to eq(first_place_post.id)
        expect(response_json[1]['id']).to eq(second_place_post.id)
        expect(response_json[2]['id']).to eq(third_place_post.id)
        expect(response_json[3]['id']).to eq(fourth_place_post.id)
        expect(response_json[4]['id']).to eq(fifth_place_post.id)
        expect(response_json[5]['id']).to eq(sixth_place_post.id)
        expect(response_json[6]['id']).to eq(seventh_place_post.id)
      end
    end
  end

  get "/api/v1/feed/top" do
    route_summary "Main Homepage Feed"
    route_description <<~DESCRIPTION
      Another standard feed approach -> sort by content from users you follow first (sorted reverse chron)
      then content from users you don't follow (sorted reverse chron)
      DESCRIPTION

    before do
      5.times { FactoryBot.create :user }
    end

    let(:user) { FactoryBot.create(:user) }
    let(:api_token) { user.api_token }

    # Score 16
    let!(:first_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      1.times {|n| post.views.create(user: User.where.not(id: user.id).sample)}
      5.times {|n| post.likes.create(user: User.where.not(id: user.id).sample)}
      post
    end

    # Score 14
    let!(:second_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      2.times {|n| post.views.create(user: User.where.not(id: user.id).sample)}
      4.times {|n| post.likes.create(user: User.where.not(id: user.id).sample)}
      post
    end

    # Score 8
    let!(:third_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      5.times {|n| post.views.create(user: User.where.not(id: user.id).sample)}
      1.times {|n| post.likes.create(user: User.where.not(id: user.id).sample)}
      post
    end

    # Score 7
    let!(:fourth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      1.times {|n| post.views.create(user: User.where.not(id: user.id).sample)}
      2.times {|n| post.likes.create(user: User.where.not(id: user.id).sample)}
      post
    end


    let!(:fifth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      post
    end

    let!(:irrelevant_sixth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      user.views.create(post: post)
      post
    end

    let!(:irrelevant_seventh_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      user.views.create(post: post)
      post
    end

    let(:raw_post) do
      {
        api_token: api_token
      }
    end

    context "401 Unauthorized" do
      let(:api_token) { nil }
      example_request "Unauthenticated Request." do
        expect(status).to be_http_status(:forbidden)
        expect(response_json).to include_json({
          "title": I18n.t("error_messages.unauthenticated_request.title")
        })
      end
    end

    context "200 OK" do
      example_request "Fetches a feed sorted by views/likes" do
        expect(status).to be_http_status(:ok)
        expect(response_json.count).to eq(4)
        expect(response_json.map{|rj| rj['id']}).to eq([
          first_place_post.id,
          second_place_post.id,
          third_place_post.id,
          fourth_place_post.id
        ])
      end
    end
  end

  get "/api/v1/feed/custom" do
    route_summary "Main Homepage Feed"
    route_description <<~DESCRIPTION
      Custom approach to a feed
      DESCRIPTION

    before do
      5.times { FactoryBot.create :user }
    end

    let(:user) { FactoryBot.create(:user) }
    let(:api_token) { user.api_token }

    let!(:posts) do
      5.times do
        FactoryBot.create(:post, user: User.all.sample)
      end
    end

    let(:raw_post) do
      {
        api_token: api_token
      }
    end

    context "401 Unauthorized" do
      let(:api_token) { nil }
      example_request "Unauthenticated Request." do
        expect(status).to be_http_status(:forbidden)
        expect(response_json).to include_json({
          "title": I18n.t("error_messages.unauthenticated_request.title")
        })
      end
    end
  end

end
