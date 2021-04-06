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

  get "/api/v1/feed/ordered_by_view_count" do
    route_summary "Main Homepage Feed"
    route_description <<~DESCRIPTION
      Slightly less naive approach to a feed -> ordered by count of views of each post
      DESCRIPTION

    before do
      5.times { FactoryBot.create :user }
    end

    let(:user) { FactoryBot.create(:user) }
    let(:api_token) { user.api_token }

    let!(:first_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      views = 7.times {|i| post.views.create(user: User.all.sample)}
      post
    end

    let!(:second_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      views = 5.times {|i| post.views.create(user: User.all.sample)}
      post
    end

    let!(:third_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      views = 3.times {|i| post.views.create(user: User.all.sample)}
      post
    end

    let!(:fourth_place_post) do
      post = FactoryBot.create(:post, user: User.all.sample)
      views = 1.times {|i| post.views.create(user: User.all.sample)}
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
      example_request "Fetches a feed sorted by view count" do
        expect(status).to be_http_status(:ok)
        expect(response_json.count).to eq(4)
        expect(response_json[0]['id']).to eq(first_place_post.id)
        expect(response_json[1]['id']).to eq(second_place_post.id)
        expect(response_json[2]['id']).to eq(third_place_post.id)
        expect(response_json[3]['id']).to eq(fourth_place_post.id)
      end
    end
  end

  get "/api/v1/feed/ordered_by_following" do
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

    let!(:followed_users) do
      5.times do
        followed_user = FactoryBot.create(:user)
        user.following << followed_user
      end
    end

    let!(:first_post_from_following) do
      FactoryBot.create(:post, user: user.following.sample)
    end
    let!(:second_post_from_following) do
      FactoryBot.create(:post, user: user.following.sample)
    end
    let!(:third_post_from_following) do
      FactoryBot.create(:post, user: user.following.sample)
    end
    let!(:fourth_post_from_following) do
      FactoryBot.create(:post, user: user.following.sample)
    end

    let!(:first_post_from_not_following) do
      FactoryBot.create(:post, user: User.where.not(id: user.following.pluck(:id)).sample)
    end
    let!(:second_post_from_not_following) do
      FactoryBot.create(:post, user: User.where.not(id: user.following.pluck(:id)).sample)
    end
    let!(:third_post_from_not_following) do
      FactoryBot.create(:post, user: User.where.not(id: user.following.pluck(:id)).sample)
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
      example_request "Fetches a feed sorted by view count" do
        expect(status).to be_http_status(:ok)
        expect(response_json.count).to eq(7)
        expect(response_json.map{|rj| rj['id']}).to eq([
          fourth_post_from_following.id,
          third_post_from_following.id,
          second_post_from_following.id,
          first_post_from_following.id,
          third_post_from_not_following.id,
          second_post_from_not_following.id,
          first_post_from_not_following.id
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
