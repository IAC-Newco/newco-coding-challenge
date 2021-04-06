module TokenGenerator
  extend ActiveSupport::Concern

  # Returns a unique token after confirming it does not already exist in the column of the specified model
  def generate_token(model, column)
    loop do
      token = SecureRandom.urlsafe_base64
      break token unless model.where("? = ?", column, token).exists?
    end
  end
end
