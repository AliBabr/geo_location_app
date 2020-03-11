# frozen_string_literal: true
class Api::V1::CoachesController < ApplicationController
  before_action :authenticate
  before_action :set_coach, only: %i[get_coach get_coach_lessons add_favorite]

  def get_coach
    ratings = []
    all_ratings = Rating.where(coach_id: @coach.id)
    all_ratings.each do |rating|
      ratings << { rating_id: rating.id, review: rating.review, rate: rating.rate }
    end
    image_url = ""
    image_url = url_for(@coach.profile_photo) if @coach.profile_photo.attached?
    render json: { coach_id: @coach.id, email: @coach.email, name: @coach.name, phone: @coach.phone, profile_photo: image_url, city: @coach.city, about: @coach.about, background: @coach.background, category: @coach.category, type: @coach.leason_type, role: @coach.role, all_ratings: ratings, averrage_rating: @coach.rating, fav_count: @coach.fav_count }, status: 200
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

  private

  def set_coach # instance methode for category
    @coach = User.find_by_id(params[:coach_id])
    if @coach.present?
      return true
    else
      render json: { message: "Coach Not found!" }, status: 404
    end
  end
end
