# frozen_string_literal: true
class Api::V1::CoachesController < ApplicationController
  before_action :authenticate
  before_action :set_coach, only: %i[get_coach get_coach_lessons add_favorite add_into_fav_coaches remove_fav_coache get_coach_earn_money_on_this_month get_coach_all_sessions]
  before_action :set_student, only: %i[add_into_fav_coaches remove_fav_coache my_fav_coaches get_student_completes_sessions get_student_spent_money_on_this_month]

  before_action :is_coach, only: %i[get_coach_total_fav get_coach_total_earnig get_coach_sessions ]
  before_action :is_student, only: %i[get_student_spent_money]

  def get_coach
    fav = Favorite.where(student_id: @current_user.id, coach_id: @coach.id)
    if fav.present?
      fav = true
    else
      fav = false
    end
    ratings = []
    all_ratings = Rating.where(coach_id: @coach.id)
    all_ratings.each do |rating|
      ratings << { rating_id: rating.id, review: rating.review, rate: rating.rate }
    end
    image_url = ""
    image_url = url_for(@coach.profile_photo) if @coach.profile_photo.attached?
    render json: { coach_id: @coach.id, email: @coach.email, name: @coach.name, phone: @coach.phone, profile_photo: image_url, city: @coach.city, about: @coach.about, background: @coach.background, category: @coach.category, type: @coach.leason_type, role: @coach.role, all_ratings: ratings, averrage_rating: @coach.rating, fav_count: @coach.fav_count, is_my_fav: fav }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    all_coaches = []
    coaches = User.where(role: "Coach").order("rating ASC")
    coaches.each do |coach|
      image_url = ""
      image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
      all_coaches << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count }
    end
    render json: all_coaches, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_lessons
    all_lesson = []
    lessons = @coach.lessons
    lessons.each do |lesson|
      all_lesson << { lesson_id: lesson.id, title: lesson.title, price: lesson.price, description: lesson.description, availability: lesson.availability, duration: lesson.duration, category: lesson.category, type: lesson.leason_type, fav_count: lesson.fav_count }
    end
    render json: all_lesson, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def search_by_name
    all_coaches = []
    coaches = User.search(params[:query])
    coaches.each do |coach|
      image_url = ""
      image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
      all_coaches << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count }
    end
    render json: all_coaches, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def search_by_category
    all_coaches = []
    categories = Category.search(params[:query])
    categories.each do |category|
      category.users.each do |coach|
        image_url = ""
        image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
        all_coaches << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count }
      end
    end
    render json: all_coaches, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_by_category
    all_coaches = []
    if params[:category_id].present? && Category.find_by_id(params[:category_id]).present?
      category = Category.find_by_id(params[:category_id])
      category.users.each do |coach|
        image_url = ""
        image_url = url_for(coach.profile_photo) if coach.profile_photo.attached?
        all_coaches << { coach_id: coach.id, email: coach.email, name: coach.name, phone: coach.phone, profile_photo: image_url, city: coach.city, about: coach.about, background: coach.background, category: coach.category, type: coach.leason_type, rating: coach.rating, fav_count: coach.fav_count }
      end
      render json: all_coaches, status: 200
    else
      render json: { message: "Please {rovide valid category id" }, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def add_favorite
    if @coach.fav_count.present?
      count = @coach.fav_count
    else
      count = 0
    end
    @coach.update(fav_count: count + 1)
    render json: { message: "Added favorite successfully..!" }
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_total_fav
    fav = @current_user.fav_count
    render json: { total_fav: fav }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_total_earnig
    bookings = Booking.where(coach_id: @current_user.id, booking_status: "done")
    price = bookings.pluck(:price)
    total_eraning = price.sum
    render json: { total: total_eraning }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_sessions
    all_sessions = []
    bookings = Booking.where(coach_id: @current_user.id, booking_status: "done")
    bookings.each do |booking|
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      all_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
    end
    render json: { sessions: all_sessions }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_student_spent_money
    bookings = @current_user.bookings.where(booking_status: "done")
    price = bookings.pluck(:price)
    total_eraning = price.sum
    render json: { total: total_eraning }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  
  def add_into_fav_coaches
    fav = Favorite.new(student_id: @student.id, coach_id: @coach.id)
    if fav.save
      render json: {message: 'Coach has been added to fav..!'}, status: 200
    else
      render json: fav.errors.messages, status: 400
    end
  end

  def remove_fav_coache
    fav = Favorite.where(student_id: @student.id, coach_id: @coach.id)
    fav.destroy_all
    render json: {message: 'Fav has been removed..!'}, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def my_fav_coaches
  favs = Favorite.where(student_id: @student.id)
  all_fav = []
  favs.each do |f|
    fav = User.find_by_id(f.coach_id)
    image_url = ""
    image_url = url_for(fav.profile_photo) if fav.profile_photo.attached?
    all_fav << { coach_id: fav.id, email: fav.email, name: fav.name, phone: fav.phone, profile_photo: image_url, city: fav.city, about: fav.about, background: fav.background, category: fav.category, type: fav.leason_type, role: fav.role }
  end
  render json: all_fav, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_student_completes_sessions
    active_bookings = []
    bookings = @student.bookings.where(booking_status: "done")
    bookings.each do |booking|
      total_booking = @current_user.bookings.where(coach_id: booking.coach_id)
      percentage = (total_booking.count % 10) * 10
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      active_bookings << { session_id: booking.id, lesson: booking.lesson, percentage: percentage, image: image_url, color: booking.lesson.category.color }
    end
    render json: {active_bookings: active_bookings, total_count: active_bookings.count}, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_student_spent_money_on_this_month
    bookings = @student.bookings.where(booking_status: "done")
    first_of_month = Date.current.beginning_of_month
    last_of_next_month = Date.current.end_of_month
    bookings.where('updated_at BETWEEN ? AND ?', first_of_month, last_of_next_month)
    price = bookings.pluck(:price)
    total_eraning = price.sum
    render json: { total: total_eraning, month: (Time.now).strftime("%B")  }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_earn_money_on_this_month
    bookings = Booking.where(booking_status: "done", coach_id: @coach.id)
    first_of_month = Date.current.beginning_of_month
    last_of_next_month = Date.current.end_of_month
    bookings.where('updated_at BETWEEN ? AND ?', first_of_month, last_of_next_month)
    price = bookings.pluck(:price)
    total_eraning = price.sum
    render json: { total: total_eraning, month: (Time.now).strftime("%B")  }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def total_session_createded_by_coach
    favs = Favorite.where(student_id: @student.id)
    all_fav = []
    favs.each do |f|
      fav = User.find_by_id(f.coach_id)
      image_url = ""
      image_url = url_for(fav.profile_photo) if fav.profile_photo.attached?
      all_fav << { coach_id: fav.id, email: fav.email, name: fav.name, phone: fav.phone, profile_photo: image_url, city: fav.city, about: fav.about, background: fav.background, category: fav.category, type: fav.leason_type, role: fav.role }
    end
    render json: all_fav, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_coach_all_sessions
    all_sessions = []
    bookings = Booking.where(coach_id: @coach.id)
    bookings.each do |booking|
      image_url = ""
      image_url = url_for(booking.lesson.category.image) if booking.lesson.category.image.attached?
      all_sessions << { session_id: booking.id, lesson: booking.lesson, image: image_url, color: booking.lesson.category.color, booking: booking }
    end
    render json: { sessions: all_sessions, total: all_sessions.count }, status: 200
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
