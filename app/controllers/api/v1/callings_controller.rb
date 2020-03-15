# frozen_string_literal: true
class Api::V1::CallingsController < ApplicationController
  before_action :authenticate
  before_action :set_calling, only: %i[destroy_calling update_calling]
  before_action :set_booking, only: %i[create update_calling]

  def create
    calling = Calling.new(calling_params)
    calling.booking_id = @booking.id
    if calling.save
      student = User.find_by_id(calling.student_id)
      coach = User.find_by_id(calling.coach_id)

      student_profile_photo = ""
      coach_profile_photo = ""
      student_profile_photo = url_for(student.profile_photo) if student.profile_photo.attached?
      coach_profile_photo = url_for(coach.profile_photo) if coach.profile_photo.attached?

      render json: { calling_id: calling.id, duration: calling.duration, time_of_call: calling.time_of_call, student_name: student.name, coach_name: coach.name, student_profile_photo: student_profile_photo, coach_profile_photo: coach_profile_photo }, status: 200
    else
      render json: calling.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def my_calling_history
    all_history = []
    as_student = Calling.where(student_id: @current_user.id)
    as_coach = Calling.where(coach_id: @current_user.id)
    histories = as_coach + as_student
    histories.each do |calling|
      student = User.find_by_id(calling.student_id)
      coach = User.find_by_id(calling.coach_id)
      student_profile_photo = ""
      coach_profile_photo = ""
      student_profile_photo = url_for(student.profile_photo) if student.profile_photo.attached?
      coach_profile_photo = url_for(coach.profile_photo) if coach.profile_photo.attached?
      all_history << { calling_id: calling.id, duration: calling.duration, time_of_call: calling.time_of_call, student_name: student.name, coach_name: coach.name, student_profile_photo: student_profile_photo, coach_profile_photo: coach_profile_photo }
    end
    render json: all_history, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_calling # instance methode for calling
    @calling = Calling.find_by_id(params[:calling_id])
    if @calling.present?
      return true
    else
      render json: { message: "calling Not found!" }, status: 404
    end
  end

  def calling_params
    params.permit(:coach_id, :student_id, :duration, :time_of_call)
  end

  def set_booking # instance methode for lesson
    @booking = Booking.find_by_id(params[:session_id])
    if @booking.present?
      return true
    else
      render json: { message: "Session Not found!" }, status: 404
    end
  end
end
