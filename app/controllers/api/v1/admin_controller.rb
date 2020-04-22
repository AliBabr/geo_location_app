# frozen_string_literal: true
class Api::V1::AdminController < ApplicationController
    before_action :authenticate
    before_action :set_coach, only: %i[all_coach_data]
    before_action :set_student, only: %i[all_student_data]
    before_action :set_booking, only: %i[session_users_data]
  
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

    def all_students
      all_coaches = []
      coaches = User.where(role: "Student").order("rating ASC")
      coaches.each do |coach|
        image_url = ""
        bookings = coach.bookings.where(booking_status: "done")
        price = bookings.pluck(:price)
        total_eraning = price.sum
        image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
        all_coaches << { student_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count, total_spent: total_eraning }
      end
      render json: all_coaches, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end

    def all_student_data
      get_student_completed_sessions()
      get_student_active_sessions()
      get_student_booking_requests()
      get_student_decline_requests()
      get_student_ratings()
      render json: { compeleted_sessions: @student_all_sessions, active_sessions: @student_active_bookings, booking_requests: @student_all_booking_requests, decline_requests: @student_all_decline_requests, ratings: @student_ratings  }, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end

    def all_coach_data
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


    def get_coach_lessons
      @coach_all_lesson = []
      lessons = @coach.lessons
      lessons.each do |lesson|
        @coach_all_lesson << { lesson_id: lesson.id, title: lesson.title, price: lesson.price, description: lesson.description, availability: lesson.availability, duration: lesson.duration, category: lesson.category, type: lesson.leason_type, fav_count: lesson.fav_count }
      end
    end

    def get_student_ratings
      @student_ratings = []
      all_ratings = Rating.where(student_id: @student.id)
      all_ratings.each do |rating|
        @student_ratings << { rating_id: rating.id, review: rating.review, rate: rating.rate, lesson: rating.booking.lesson }
      end
    end

    def get_coach_ratings
      @coach_ratings = []
      all_ratings = Rating.where(coach_id: @coach.id)
      all_ratings.each do |rating|
        @coach_ratings << { rating_id: rating.id, review: rating.review, rate: rating.rate, lesson: rating.booking.lesson }
      end
    end

    def get_student_completed_sessions
      @student_all_sessions = []
      bookings = @student.bookings.where(booking_status: "done")
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @student_all_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
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

    def all_sessions
      @done_sessions = []
      bookings = Booking.where( booking_status: "done")
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @done_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
      end

      @active_sessions = []
      bookings = Booking.where( booking_status: "active")
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @active_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
      end
      render json: {done_sessions: @done_sessions, active_sessions: @active_sessions}, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end

    def session_users_data
      coache_data = []
      student_data = []
      student = @booking.user
      coach = User.find_by_id(@booking.coach_id)

      image_url = ""
      bookings = Booking.where(coach_id: coach.id, booking_status: "done")
      price = bookings.pluck(:price)
      total_eraning = price.sum
      image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
      coache_data << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count, earning: total_eraning }

      image_url = ""
      bookings = student.bookings.where(booking_status: "done")
      price = bookings.pluck(:price)
      total_eraning = price.sum
      image_url = url_for(student.profile_photo) if student.profile_photo.attached?
      student_data << { student_id: student.id, email: student.email, name: student.name, phone: student.phone, profile_photo: image_url, city: student.city, about: student.about, background: student.background, category: student.category, type: student.leason_type, rating: student.rating, fav_count: coach.fav_count, total_spent: total_eraning }

      render json: {coache_data: coache_data, student_data: student_data}, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end


    def get_student_active_sessions
      @student_active_bookings = []
      bookings = @student.bookings.where(booking_status: "active")
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @student_active_bookings << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color }
      end
    end

    def get_coach_active_sessions
      @coach_active_bookings = []
      bookings = Booking.where(booking_status: "active", coach_id: @coach.id)
      bookings.each do |booking|
        image_url = ""
        image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
        @coach_active_bookings << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color }
      end
    end

    def get_student_booking_requests
      @student_all_booking_requests = []
      bookings = @student.bookings.where(request_status: "sent")
      bookings.each do |booking|
        @student_all_booking_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end

    def get_coach_booking_requests
      @coach_all_booking_requests = []
      bookings = Booking.where(coach_id: @coach.id, request_status: "sent")
      bookings.each do |booking|
        @coach_all_booking_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end

    def get_student_decline_requests
      @student_all_decline_requests = []
      bookings = @student.bookings.where(request_status: "decline")
      bookings.each do |booking|
        @student_all_decline_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end

    def get_coach_decline_requests
      @coach_all_decline_requests = []
      bookings = Booking.where(coach_id: @coach.id, request_status: "decline")
      bookings.each do |booking|
        @coach_all_decline_requests << { booking_id: booking.id, start_time: booking.start_time, end_time: booking.end_time, payment_sttus: booking.payment_status, lesson: booking.lesson, type: booking.lesson.leason_type, category: booking.lesson.category }
      end
    end
  
    private

    def set_booking
      @booking = Booking.find_by_id(params[:id])
      if @booking.present?
        return true
      else
        render json: { message: "Coach Not found!" }, status: 404
      end
    end
  
    def set_coach # instance methode for category
      @coach = User.find_by_id(params[:coach_id])
      if @coach.present?
        return true
      else
        render json: { message: "Coach Not found!" }, status: 404
      end
    end
  
    def set_student # instance methode for category
      @student = User.find_by_id(params[:student_id])
      if @student.present?
        return true
      else
        render json: { message: "student Not found!" }, status: 404
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
  