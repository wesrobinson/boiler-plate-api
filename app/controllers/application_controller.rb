class ApplicationController < ActionController::Base
  include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

  rescue_from ActionController::ParameterMissing do |e|
    respond_to do |format|
      format.json do
        render json: {error: e.message}, status: :bad_request
      end
    end
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    respond_to do |format|
      format.json do
        render json: {error: e.message}, status: :not_acceptable
      end
    end
  end

  def respond_with(*args)
    return super unless request.format == :json

    render_args = {json: args.first.to_json}
    render_args.merge!(args[1]) if args[1]

    render render_args
  end

  def home
    render json: "Welcome to your new app!"
  end

end
