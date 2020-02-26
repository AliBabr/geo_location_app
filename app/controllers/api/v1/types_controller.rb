# frozen_string_literal: true
class Api::V1::TypesController < ApplicationController
  before_action :authenticate, except: [:index]
  before_action :set_type, only: %i[destroy_type update_type]
  before_action :is_admin, only: %i[create destroy_type update_type]

  def create
    type = LeasonType.new(type_params)
    if type.save
      image_url = ""
      image_url = url_for(type.image) if type.image.attached?
      render json: { type_id: type.id, name: type.name, color: type.color, description: type.description, image: image_url }, status: 200
    else
      render json: type.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def update_type
    @type.update(type_params)
    if @type.errors.any?
      render json: @type.errors.messages, status: 400
    else
      image_url = ""
      image_url = url_for(@type.image) if @type.image.attached?
      render json: { type_id: @type.id, name: @type.name, color: @type.color, description: @type.description, image: image_url }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    types = LeasonType.all; all_types = []
    types.each do |type|
      image_url = ""
      image_url = url_for(type.image) if type.image.attached?
      all_types << { type_id: type.id, name: type.name, color: type.color, description: type.description, image: image_url }
    end
    render json: all_types, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_type
    @type.destroy
    render json: { message: "type deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_type # instance methode for type
    @type = LeasonType.find_by_id(params[:type_id])
    if @type.present?
      return true
    else
      render json: { message: "type Not found!" }, status: 404
    end
  end

  def type_params
    params.permit(:name, :description, :image, :color)
  end

  def is_admin
    if @current_user.role == "Admin"
      true
    else
      render json: { message: "Only admin can create/update/destroy types!" }
    end
  end
end
