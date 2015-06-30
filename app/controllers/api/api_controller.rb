# All Api controllers should inherit from this class
class Api::ApiController < ApplicationController
  # remove session handling, allowing CSRF for API
  protect_from_forgery with: :null_session
  # requires Api key to move forward, redirects to login
  before_filter :authenticate_apiKey
  # opens Api to all requests
  before_filter :set_headers_for_api
  # TODO: remove flash, assets, cookies, etc

  respond_to :json
  # skip rendering layouts
  layout nil

  protected

  ## DANGER PLEASE READ
  # set_headers_for_api makes this API publicly available to anyone on the internet
  # Use caution to ensure every request is authenticated and does not respond with unathorized information
  # Prevents checking of 'Cross-origin Resource Sharing (CORS)'
  def set_headers_for_api
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def authenticate_apiKey
    if request.headers['X-Api-Key'].blank?
      # fail!
      return render :json => { :error => "Please provide an API Key" }, :status => :unauthorized, :location => new_user_session_path 
    else
      @user = User.find_by_access_token(request.headers['X-Api-Key'])
      unless @user
        # fail!
        return render :json => { :error => "Your API Key is incorrect or expired, please sign in again"}, :status => :unauthorized, :location => new_user_session_path
      end
      # pass!
    end
  end  
end

