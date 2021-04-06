module SessionsHelper
  def current_user
    @current_user
  end

  def log_out
    # session[:user_id] = nil
    current_user = nil
  end
end
