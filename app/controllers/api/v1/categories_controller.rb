# frozen_string_literal: true
class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate, except: [:index]
  before_action :set_category, only: %i[destroy_category update_category]
  before_action :is_admin, only: %i[create destroy_category update_category]

  def create
    category = Category.new(category_params)
    if category.save
      image_url = ""
      image_url = url_for(category.image) if category.image.attached?
      render json: { category_id: category.id, name: category.name, color: category.color, description: category.description, image: image_url }, status: 200
    else
      render json: category.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def update_category
    @category.update(category_params)
    if @category.errors.any?
      render json: @category.errors.messages, status: 400
    else
      image_url = ""
      image_url = url_for(@category.image) if @category.image.attached?
      render json: { category_id: @category.id, name: @category.name, color: @category.color, description: @category.description, image: image_url }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    categories = Category.all; all_Categories = []
    categories.each do |category|
      image_url = ""
      image_url = url_for(category.image) if category.image.attached?
      all_Categories << { category_id: category.id, name: category.name, color: category.color, description: category.description, image: image_url }
    end
    render json: all_Categories, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_category
    @category.destroy
    render json: { message: "category deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_category # instance methode for category
    @category = Category.find_by_id(params[:category_id])
    if @category.present?
      return true
    else
      render json: { message: "category Not found!" }, status: 404
    end
  end

  def category_params
    params.permit(:name, :description, :image, :color)
  end

  def is_admin
    if @current_user.role == "Admin"
      true
    else
      render json: { message: "Only admin can create/update/destroy Categories!" }
    end
  end
end
