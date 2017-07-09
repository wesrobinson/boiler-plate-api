class UsersController < ApplicationController
  CURRENT_USER_IDENTIFIER = 'me'
  acts_as_token_authentication_handler_for User, except: :create

  # Rescue errors specific to this resource with the following syntax and create custom error message if necessary
  # rescue_from Error::Name do |e|
  #   respond_to do |format|
  #     format.json do
  #       message = e.message
  #       render json: message, status: :not_acceptable
  #     end
  #   end
  # end

  def create
    if params[:channel_id]
      channel_id = params[:channel_id]
      channel_ids = [channel_id]
      @user = User.create!(create_params.merge(channel_ids: channel_ids))
    else
      @user = User.create!(create_params)
    end
    respond_with @user.response_attributes
  end

  def update
    @user = User.find(params[:id])
    if params[:channel_id]
      channel_ids = @user.channel_ids << params[:channel_id]
      @user.update!(update_params.merge(channel_ids: channel_ids.uniq))
    else
      @user.update!(update_params)
    end
    respond_with @user
  end

  def show
    id = params.require(:id)
    if id == CURRENT_USER_IDENTIFIER
      @user = current_user
    else
      @user = User.find(id)
    end
    if params[:channel_id]
      channel_ids = @user.channel_ids << params[:channel_id]
      @user.update!(update_params.merge(channel_ids: channel_ids.uniq))
    end
    respond_with @user
  end

  protected

  def create_params
    params.require(:full_name)
    params.require(:email)
    params.require(:password)
    params.permit(:full_name, :email, :password)
  end

  def update_params
    params.permit(
      :full_name,
      :email,
      :password,
      :in_setup,
      :phone,
      :avatar_image,
      :avatar_url,
      :receive_app_notifications
    )
  end
end