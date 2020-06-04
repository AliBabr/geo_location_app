class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: %i[update_account update_password user_data log_out get_user delete_account] # callback for validating user
  before_action :forgot_validation, only: [:forgot_password]
  before_action :before_reset, only: [:reset_password]
  before_action :set_user, only: %i[get_user delete_account add_twilio_token]

  # Method which accept credential from user and sign in and return user data with authentication token
  def sign_in
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        image_url = ""
        image_url = url_for(user.profile_photo) if user.profile_photo.attached?
        if user.role == "Coach"
          render json: { user_id: user.id, role: user.role , email: user.email, name: user.name, phone: user.phone, profile_photo: image_url, city: user.city, about: user.about, background: user.background, category: user.category, twilio_token: user.twilio_token , type: user.leason_type, "UUID" => user.id, "Authentication" => user.authentication_token }, status: 200
        else
          render json: { user_id: user.id, role: user.role, email: user.email, name: user.name, phone: user.phone, profile_photo: image_url, twilio_token: user.twilio_token, city: user.city, "UUID" => user.id, "Authentication" => user.authentication_token }, status: 200
        end
      else
        render json: { message: "No Email and Password matching that account were found" }, status: 400
      end
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: "Error: Something went wrong... " }, status: 400
  end

  def get_user
    image_url = ""
    image_url = url_for(@user.profile_photo) if @user.profile_photo.attached?
    if @user.role == "Coach"
      render json: { user_id: @user.id, email: @user.email, name: @user.name, phone: @user.phone, profile_photo: image_url, city: @user.city, about: @user.about, background: @user.background, category: @user.category, type: @user.leason_type, role: @user.role, twilio_token: @user.twilio_token }, status: 200
    else
      render json: { user_id: @user.id, email: @user.email, name: @user.name, phone: @user.phone, profile_photo: image_url, city: @user.city, role: @user.role }, status: 200
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: "Error: Something went wrong... " }, status: 400
  end

  # Method which accepts parameters from user and save data in db
  def sign_up
    user = User.new(user_params); user.id = SecureRandom.uuid # genrating secure uuid token
    if params[:role].present? && params[:role] == "Coach"
      set_type_n_category
      if @category.present? && @type.present?
        user.category_id = @category.id
        user.leason_type_id = @type.id
      end
    end
    if user.save
      image_url = ""
      image_url = url_for(user.profile_photo) if user.profile_photo.attached?
      if user.role == "Coach"
        render json: { user_id: user.id, email: user.email, name: user.name, phone: user.phone , twilio_token: user.twilio_token, profile_photo: image_url, city: user.city, about: user.about, background: user.background, category: user.category, type: user.leason_type, "UUID" => user.id, "Authentication" => user.authentication_token }, status: 200
      else
        render json: { user_id: user.id, email: user.email, name: user.name, phone: user.phone , twilio_token: user.twilio_token, profile_photo: image_url, city: user.city, "UUID" => user.id, "Authentication" => user.authentication_token }, status: 200
      end
    else
      render json: user.errors.messages, status: 400
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: "Error: Something went wrong... #{e}" }, status: 400
  end

  # Method that expire user session
  def log_out
    @current_user.update(authentication_token: nil)
    render json: { message: "Logged out successfuly!" }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def delete_account
    @user.destroy
    render json: { message: "account deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def add_twilio_token
    @user.update(user_params)
    if @user.errors.any?
      render json: @user.errors.messages, status: 400
    else
      image_url = ""
      image_url = url_for(@user.profile_photo) if @user.profile_photo.attached?
      if @user.role == "Coach"
        render json: { current_user_id: @user.id, email: @user.email, name: @user.name, phone: @user.phone, profile_photo: image_url, city: @user.city, twilio_token: @user.twilio_token, about: @user.about, background: @user.background, category: @user.category, type: @user.leason_type }, status: 200
      else
        render json: { current_user_id: @user.id, email: @user.email, name: @user.name, phone: @user.phone, profile_photo: image_url, city: @user.city , twilio_token: @user.twilio_token }, status: 200
      end
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... #{e}" }, status: :bad_request
  end


  # Method take parameters and update user account
  def update_account
    @current_user.update(user_params)
    if @current_user.errors.any?
      render json: @current_user.errors.messages, status: 400
    else
      image_url = ""
      image_url = url_for(@current_user.profile_photo) if @current_user.profile_photo.attached?
      if @current_user.role == "Coach"
        render json: { current_user_id: @current_user.id, email: @current_user.email, name: @current_user.name, phone: @current_user.phone, profile_photo: image_url, city: @current_user.city, about: @current_user.about, background: @current_user.background, category: @current_user.category, type: @current_user.leason_type }, status: 200
      else
        render json: { current_user_id: @current_user.id, email: @current_user.email, name: @current_user.name, phone: @current_user.phone, profile_photo: image_url, city: @current_user.city }, status: 200
      end
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  # Method take current password and new password and update password
  def update_password
    if params[:current_password].present? && @current_user.valid_password?(params[:current_password])
      @current_user.update(password: params[:new_password])
      if @current_user.errors.any?
        render json: @current_user.errors.messages, status: 400
      else
        render json: { message: "Password updated successfully!" }, status: 200
      end
    else
      render json: { message: "Current Password is not present or invalid!" }, status: 400
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  # Method that render reset password form
  def reset
    @token = params[:tokens]
    @id = params[:id]
  end

  

  # Method that send email while user forgot password
  def forgot_password
    user = User.find_by_email(params[:email])
    if user.present?
      if params[:password].present? && params[:confirm_password].present?
        if params[:password] == params[:confirm_password]
          user.update(password: params[:password], password_confirmation: params[:confirm_password])
          if user.errors.any?
            render json: user.errors.messages, status: 400
          else
            render json: {message: 'Password reset successfully'}, status: 200
          end
        else
          render json: {message: 'Password and confirm password should match'}, status: 400
        end
      else
        render json: {message: 'Password and confirm password can not be blank'}, status: 400
      end
    else
      render json: { message: "User not found with provided email..!" }, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong...#{e} " }, status: :bad_request
  end

  # Method that take new password and confirm password and reset user password
  def reset_password
    if (params[:token] === @current_user.reset_token) && (@current_user.updated_at > DateTime.now - 1)
      @current_user.update(password: params[:password], password_confirmation: params[:confirm_password], reset_token: "")
      render "reset" if @current_user.errors.any?
    else
      @error = "Token is expired"; render "reset"
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end



  private

  def user_params # permit user params
    params.permit(:email, :password, :name, :city, :profile_photo, :phone, :about, :background, :role, :twilio_token)
  end

  # Helper method for forgot password method
  def forgot_validation
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }, status: 400
    else
      @current_user = User.where(email: params[:email]).first
      if @current_user.present?
        o = [("a".."z"), ("A".."Z")].map(&:to_a).flatten; @token = (0...15).map { o[rand(o.length)] }.join
      else
        render json: { message: "Invalid Email!" }, status: 400
      end
    end
  end

  # Helper method for reset password method
  def before_reset
    @id = params[:id]; @token = params[:token]; @current_user = User.find_by_id(params[:id])
    if params[:password] == params[:confirm_password]
      return true
    else
      @error = "Password and confirm password should match"
      render "reset"
    end
  end

  def set_user
    @user = User.find_by_id(params[:user_id])
    if @user.present?
      true
    else
      render json: { message: "Provide valid user ID" }, status: 400
    end
  end

  def set_type_n_category
    if (params[:type_id].present? && LeasonType.find_by_id(params[:type_id]).present?) && (params[:category_id].present? && Category.find_by_id(params[:category_id]).present?)
      @category = Category.find_by_id(params[:category_id])
      @type = LeasonType.find_by_id(params[:type_id])
    end
  end
end
