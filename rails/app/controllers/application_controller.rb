class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_user
    return nil unless request.headers['X-User-Id'].present?

    @current_user ||= User.find_by(id: request.headers['X-User-Id'])
  end

  def not_found(e)
    render json: { error: e.message }, status: :not_found
  end
end
