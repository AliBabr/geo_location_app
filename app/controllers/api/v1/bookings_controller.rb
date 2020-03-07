# frozen_string_literal: true
class Api::V1::BookingsController < ApplicationController
  before_action :authenticate
  before_action :is_student, only: %i[create]
  before_action :is_coach, only: %i[accept_or_decline_booking]
  before_action :set_user, only: %i[get_coach_booking_requests get_student_bookings]
  before_action :set_booking, only: %i[accept_or_decline_booking update_booking get_booking destroy_booking]
  before_action :set_lesson, only: %i[create]

  def create
    booking = Booking.new(booking_params)
    booking.user_id = @current_user.id
    booking.lesson_id = @lesson.id
    booking.booking_status = "inactive"
    booking.payment_status = "pending"
    booking.request_status = "sent"
    booking.coach_id = @lesson.user.id
    booking.price = @lesson.price
    if booking.save
      render json: { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: @lesson.leason_type, category: @lesson.category }, status: 200
    else
      render json: booking.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_booking_requests
    all_requests = []
    bookings = Booking.where(coach_id: @user.id, request_status: "sent")
    bookings.each do |booking|
      all_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
    end
    render json: all_requests, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_student_bookings
    all_requests = []
    bookings = @user.bookings
    bookings.each do |booking|
      all_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, request_status: booking.request_status, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
    end
    render json: all_requests, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def accept_or_decline_booking
    if params[:status] == "accept" || params[:status] == "decline"
      status = params[:status]
      @booking.update(request_status: status)
      if @booking.errors.any?
        render json: @booking.errors.messages, status: 400
      else
        render json: { message: "Booking request status has been saved..!" }, status: 200
      end
    else
      render json: { message: "Please provide valid option" }, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def update_booking
    @booking.update(booking_params)
    if @booking.errors.any?
      render json: @lesson.errors.messages, status: 400
    else
      render json: { booking_id: @booking.id, request_status: @booking.request_status, start_time: @booking.start_time, end_time: @booking.end_time, payment_sttus: @booking.payment_status, lesson: @booking.lesson, type: @booking.lesson.leason_type, category: @booking.lesson.category }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_booking
    render json: { booking_id: @booking.id, request_status: @booking.request_status, start_time: @booking.start_time, end_time: @booking.end_time, payment_sttus: @booking.payment_status, lesson: @booking.lesson, type: @booking.lesson.leason_type, category: @booking.lesson.category }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_booking
    @booking.destroy
    render json: { message: "Booking deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_lesson # instance methode for lesson
    @lesson = Lesson.find_by_id(params[:lesson_id])
    if @lesson.present?
      return true
    else
      render json: { message: "lesson Not found!" }, status: 404
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

  def booking_params
    params.permit(:start_time, :end_time)
  end

  def is_student
    if @current_user.role == "Student"
      true
    else
      render json: { message: "Only Student can create booking..!" }, status: 400
    end
  end

  def is_coach
    if @current_user.role == "Coach"
      true
    else
      render json: { message: "Only Coach can accep or decline booking request !" }, status: 400
    end
  end

  def set_user
    @user = User.find_by_id(params[:user_id])
    if @user.present?
      return true
    else
      render json: { message: "User Not found!" }, status: 404
    end
  end
end