class Api::V1::FeedController < ApiController

  def ordered_by_creation
    # Very naive feed approach based simply on created at timestamp
    @posts = Post.order(created_at: :desc)

    render json: @posts.map{|post| post_json(post)}
  end

  def ordered_by_view_count
    # TODO: Implement a feed based on view count of a post
    # Sort -> Based on descending order of post view count

    render json: @posts.map{|post| post_json(post)}
  end

  def ordered_by_following
    # TODO: Implement a feed based on the following and post creation timestamp
    # Sort -> A user should first see content from users that they follow and then from
    # users that they do not follow. Within both of those subsets, order the content reverse
    # chronologically

    render json: @posts.map{|post| post_json(post)}
  end

  def custom
    # TODO: Construct a custom feed based on logic that you think describes a well implemented feed 
    # Sort -> any logic that produces sensible and popular content for a user

    render json: @posts.map{|post| post_json(post)}
  end

  private

  def post_json(post)
    {
      id: post.id,
      content: post.content,
      view_count: post.views.count,
      like_count: post.likes.count,
      user: post_user_json(post.user),
      created_at: post.created_at,
    }
  end

  def post_user_json(user)
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name
    }
  end

end
