# frozen_string_literal: true
class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate
  before_action :set_user, only: %i[add_card_token]
  before_action :is_student, only: %i[add_card_token]
  before_action :set_booking, only: %i[process_payment]

  def process_payment
    user = @booking.user
    lesson = @booking.lesson
    if user.stripe_cutomer_id.present?
      response = StripePayment.new(user).donate(@booking.price, user.stripe_cutomer_id)
      if response.present?
        @booking.update(payment_status: "sent", booking_status: "active")
        render json: { message: "Payemnt has been sent successfully..!" }
      else
        render json: { message: "Something went wrong please check your card token" }
      end
    else
      render json: { message: "Please Add first user card token..!" }, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def add_card_token
    if params[:card_token].present?
      response = StripePayment.new(@user).create_customer(params[:card_token])
      if response
        render json: { message: "Token saved successfully!" }, status: 200
      else
        render json: { message: "Invalid Token!" }, status: 401
      end
    else
      render json: { message: "Please provide card token" }
    end
  end

  private

  def set_user # instance methode for office
    @user = User.find_by_id(params[:user_id])
    if @user.present?
      return true
    else
      render json: { message: "User Not found!" }, status: 404
    end
  end

  def is_student
    if @current_user.role == "Student"
      true
    else
      render json: { message: "Only Student add card token...!" }, status: 400
    end
  end

  def set_booking # instance methode for lesson
    @booking = Booking.find_by_id(params[:booking_id])
    if @booking.present?
      return true
    else
      render json: { message: "Booking Not found!" }, status: 404
    end
  end
end
