# frozen_string_literal: true

module ErrorResponsesHelper
  def render_unauthorized_request(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: 'Forbidden' }, status: :forbidden
  end

  def render_not_found(message = 'Not Found')
    render json: { error: message }, status: :not_found
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
