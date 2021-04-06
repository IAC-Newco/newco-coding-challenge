class ApiController < ActionController::API
  include SessionsHelper

  before_action :authenticate_user

  def authenticate_user
    render_json :forbidden, :unauthenticated_request and return unless params[:api_token].present?
    @current_user = User.find_by(api_token: params[:api_token])
    render_json :forbidden, :unauthenticated_request and return unless @current_user.present?
  end

  protected

  def render_json(status, code=nil, object: nil, extra: {})
    return render_json_success(code, extra) if status == :ok
    status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a? Symbol
    title = I18n.t("error_messages.#{code}.title")
    messages = [I18n.t("error_messages.#{code}.message", default: nil)].compact
    messages = object.errors.full_messages if object.present?
    render json: { title: title, errors: messages }.merge(extra), status: status
  end

end
