# frozen_string_literal: true
class Api::V1::SessionsController < ApplicationController
  before_action :authenticate
  before_action :set_booking, only: %i[cancel_session]


  def get_student_active_sessions
    active_bookings = []
    bookings = @current_user.bookings.where(booking_status: "active")
    bookings.each do |booking|
      total_booking = @current_user.bookings.where(coach_id: booking.coach_id)
      percentage = (total_booking.count % 10) * 10
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      active_bookings << { session_id: booking.id, lesson: booking.lesson, percentage: percentage, image: image_url, color: booking.lesson.category.color }
    end
    render json: active_bookings, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_sessions_sorted_by_dates
    all_bookings = []
    bookings = @current_user.bookings.where("start_time > ? AND start_time < ?", Time.now.beginning_of_month, Time.now.end_of_month)
    bookings.each do |booking|
      total_booking = @current_user.bookings.where(coach_id: booking.coach_id)
      percentage = (total_booking.count % 10) * 10
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      all_bookings << { session_id: booking.id, booking: booking, lesson: booking.lesson, percentage: percentage, image: image_url, color: booking.lesson.category.color, date: booking.start_time }
    end
    render json: all_bookings, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_session_by_date
    if params[:date].present?
      # format => '2020-03-06'
      date = Date.parse(params[:date])
      bookings = Booking.where("Date(start_time) = ?", date)
      all_bookings = []
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        profile_pic = ""
        profile_url = url_for(booking.lesson.user.profile_photo) if booking.lesson.user.profile_photo.attached?
        all_bookings << { session_id: booking.id, booking: booking, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, date: booking.start_time, profile_pic: profile_url, coach_name: booking.lesson.user.name }
      end
      render json: all_bookings, status: 200
    else
      render json: { message: "Please provide date" }
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_session_by_id
    if params[:session_id].present? && Booking.find_by_id(params[:session_id]).present?
      booking = Booking.find_by_id(params[:session_id])
      all_bookings = []
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      profile_pic = ""
      profile_url = url_for(booking.lesson.user.profile_photo) if booking.lesson.user.profile_photo.attached?
      coaches = booking.lesson.category.users
      all_bookings << { session_id: booking.id, booking: booking, lesson: booking.lesson, image: image_url, category: booking.lesson.category, type: booking.lesson.leason_type, date: booking.start_time, profile_pic: profile_url, coach_name: booking.lesson.user.name, coaches_for_category: coaches }
      render json: all_bookings, status: 200
    else
      render json: { message: "Please provide valid session id..!" }
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def cancel_session
      status = 'cancel'
      @booking.update(request_status: status)
      if @booking.errors.any?
        render json: @booking.errors.messages, status: 400
      else
        render json: { message: "Session has been canceled..!" }, status: 200
      end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end


  private

  def set_booking # instance methode for lesson
    @booking = Booking.find_by_id(params[:session_id])
    if @booking.present?
      return true
    else
      render json: { message: "Booking Not found!" }, status: 404
    end
  end
end
