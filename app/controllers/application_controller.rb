class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :resource, :resource_name, :devise_mapping, :resource_class
  before_filter :store_current_location, :unless => :devise_controller?

  def index

  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || request.referrer
  end

  def authenticate_admin!
    if user_signed_in?
      redirect_to edit_user_registration_path unless current_user.admin?
    else
      redirect_to root_path
    end
  end

  private
  # override the devise helper to store the current location so we can
  # redirect to it after loggin in or out. This override makes signing in
  # and signing up work automatically.
  def store_current_location
    store_location_for(:user, request.url)
  end
end
