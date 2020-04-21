# frozen_string_literal: true
class Api::V1::AdminController < ApplicationController
    before_action :authenticate
    before_action :set_coach, only: %i[all_coach_data]
    before_action :is_coach, only: %i[get_coach_total_fav get_coach_total_earnig get_coach_sessions]
    before_action :is_student, only: %i[get_student_spent_money]
  
    def all_coaches
      all_coaches = []
      coaches = User.where(role: "Coach").order("rating ASC")
      coaches.each do |coach|
        image_url = ""
        bookings = Booking.where(coach_id: coach.id, booking_status: "done")
        price = bookings.pluck(:price)
        total_eraning = price.sum
        image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
        all_coaches << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count, earning: total_eraning }
      end
      render json: all_coaches, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end
  
    def get_coach_lessons
      @coach_all_lesson = []
      lessons = @coach.lessons
      lessons.each do |lesson|
        @coach_all_lesson << { lesson_id: lesson.id, title: lesson.title, price: lesson.price, description: lesson.description, availability: lesson.availability, duration: lesson.duration, category: lesson.category, type: lesson.leason_type, fav_count: lesson.fav_count }
      end
    end
 
    def all_coach_data
      # debugger
      get_coach_lessons()
      get_coach_completed_sessions()
      get_coach_active_sessions()
      get_coach_booking_requests()
      get_coach_decline_requests()
      get_coach_ratings()
      render json: {lessons: @coach_all_lesson, compeleted_sessions: @coach_all_sessions, active_sessions: @coach_active_bookings, booking_requests: @coach_all_booking_requests, decline_requests: @coach_all_decline_requests, ratings: @coach_ratings  }, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end

    def get_coach_ratings
      # debugger
      @coach_ratings = []
      all_ratings = Rating.where(coach_id: @coach.id)
      all_ratings.each do |rating|
        @coach_ratings << { rating_id: rating.id, review: rating.review, rate: rating.rate, lesson: rating.booking.lesson }
      end
    end

    def get_coach_completed_sessions
      @coach_all_sessions = []
      bookings = Booking.where(coach_id: @coach.id, booking_status: "done")
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @coach_all_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
      end
    end


    def get_coach_active_sessions
      @coach_active_bookings = []
      bookings = Booking.where(booking_status: "active", coach_id: @coach.id)
      bookings.each do |booking|
        total_booking = @current_user.bookings.where(coach_id: booking.coach_id)
        percentage = (total_booking.count % 10) * 10
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @coach_active_bookings << { session_id: booking.id, lesson: booking.lesson, percentage: percentage, image: image_url, color: booking.lesson.category.color }
      end
    end

    def get_coach_booking_requests
      @coach_all_booking_requests = []
      bookings = Booking.where(coach_id: @coach.id, request_status: "sent")
      bookings.each do |booking|
        @coach_all_booking_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end

    def get_coach_decline_requests
      @coach_all_decline_requests = []
      bookings = Booking.where(coach_id: @coach.id, request_status: "decline")
      bookings.each do |booking|
        @coach_all_decline_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end
  
    def get_student_spent_money
      bookings = @current_user.bookings.where(booking_status: "done")
      price = bookings.pluck(:price)
      total_eraning = price.sum
      render json: { total: total_eraning }, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end
  
    private
  
    def set_coach # instance methode for category
      @coach = User.find_by_id(params[:coach_id])
      if @coach.present?
        return true
      else
        render json: { message: "Coach Not found!" }, status: 404
      end
    end
  
    def is_coach
      if @current_user.role == "Coach"
        true
      else
        render json: { message: "Only Coach can perform this action!" }
      end
    end
  
    def is_student
      if @current_user.role == "Student"
        true
      else
        render json: { message: "Only student can perform this action!" }
      end
    end
  end
  