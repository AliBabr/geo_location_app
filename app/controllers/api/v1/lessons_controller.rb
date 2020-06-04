# frozen_string_literal: true
class Api::V1::LessonsController < ApplicationController
  before_action :authenticate
  before_action :is_coach, except: [:add_favorite]
  before_action :set_lesson, only: %i[destroy_lesson update_lesson get_lesson add_favorite]

  def create
    lesson = Lesson.new(lesson_params)
    lesson.user_id = @current_user.id
    lesson.category_id = @current_user.category.id
    lesson.leason_type_id = @current_user.leason_type.id
    if lesson.save
      render json: { lesson_id: lesson.id, title: lesson.title, price: lesson.price, description: lesson.description, availability: lesson.availability, duration: lesson.duration, category: lesson.category, type: lesson.leason_type, spots: lesson.spots }, status: 200
    else
      render json: lesson.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def update_lesson
    @lesson.update(lesson_params)
    if @lesson.errors.any?
      render json: @lesson.errors.messages, status: 400
    else
      render json: { lesson_id: @lesson.id, title: @lesson.title, price: @lesson.price, description: @lesson.description, availability: @lesson.availability, duration: @lesson.duration, category: @lesson.category, type: @lesson.leason_type, spots: @lesson.spots }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_lesson
    render json: { lesson_id: @lesson.id, title: @lesson.title, price: @lesson.price, description: @lesson.description, availability: @lesson.availability, duration: @lesson.duration, category: @lesson.category, type: @lesson.leason_type, spots: @lesson.spots }, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    lessons = Lesson.all; all_lessons = []
    lessons.each do |lesson|
      all_lessons << { lesson_id: lesson.id, title: lesson.title, price: lesson.price, description: lesson.description, availability: lesson.availability, duration: lesson.duration, category: lesson.category, type: lesson.leason_type, spots: lesson.spots }
    end
    render json: all_lessons, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_lesson
    @lesson.destroy
    render json: { message: "lesson deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def add_favorite
    if @lesson.fav_count.present?
      count = @lesson.fav_count
    else
      count = 0
    end
    @lesson.update(fav_count: count + 1)
    render json: { message: "Added favorites successfully..!" }
  rescue StandardError => e
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

  def lesson_params
    params.permit(:title, :description, :price, :availability, :duration, :spots)
  end

  def is_coach
    if @current_user.role == "Coach"
      true
    else
      render json: { message: "Only Coach can create/update/destroy Lessons!" }
    end
  end
end
