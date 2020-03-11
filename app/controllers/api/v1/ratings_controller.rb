# frozen_string_literal: true
class Api::V1::RatingsController < ApplicationController
  before_action :authenticate
  before_action :set_session
  before_action :is_student
  before_action :validate_session

  def create
    rating = Rating.new(rating_params)
    rating.coach_id = @session.coach_id
    rating.student_id = @session.user_id
    rating.booking_id = @session.id
    if rating.save
      update_coach_rating
      render json: { rating_id: rating.id, review: rating.review, rate: rating.rate }, status: 200
    else
      render json: rating.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def update_coach_rating
    rate = Rating.where(coach_id: @session.coach_id).pluck(:rate)
    if rate.present?
      User.find_by_id(@session.coach_id).update(rating: rate.sum / rate.count)
    end
  end

  def set_session # instance methode for rating
    @session = Booking.find_by_id(params[:session_id])
    if @session.present?
      return true
    else
      render json: { message: "session Not found!" }, status: 404
    end
  end

  def rating_params
    params.permit(:rate, :review)
  end

  def is_student
    if @current_user.role == "Student"
      true
    else
      render json: { message: "Only Student can add or delete ratings!" }
    end
  end

  def validate_session
    if @current_user.bookings.find_by_id(params[:session_id]).present?
      return true
    else
      render json: { message: "Student can only rate on sessions that he booked..!" }
    end
  end
end
