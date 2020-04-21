# frozen_string_literal: true
class Api::V1::ImagesController < ApplicationController
    before_action :authenticate, except: [:index]
    before_action :set_type, only: %i[destroy_image ]
  
    def create
      new_image = Image.new(image_params)
      if new_image.save
        image_url = ""
        image_url = url_for(new_image.image) if new_image.image.attached?
        render json: { id: new_image.id, description: new_image.description, image: image_url }, status: 200
      else
        render json: type.errors.messages, status: 400
      end
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end
  
    def index
      types = Image.all; all_types = []
      types.each do |type|
        image_url = ""
        image_url = url_for(type.image) if type.image.attached?
        all_types << { id: type.id, description: type.description, image: image_url }
      end
      render json: all_types, status: 200
    rescue StandardError => e
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end
  
    def destroy_image
      @new_image.destroy
      render json: { message: "image deleted successfully!" }, status: 200
    rescue StandardError => e # rescu if any exception occure
      render json: { message: "Error: Something went wrong... " }, status: :bad_request
    end
  
    private
  
    def set_type # instance methode for type
      @new_image = Image.find_by_id(params[:id])
      if @new_image.present?
        return true
      else
        render json: { message: "image Not found!" }, status: 404
      end
    end
  
    def image_params
      params.permit(:description, :image)
    end
  
    def is_admin
      if @current_user.role == "Admin"
        true
      else
        render json: { message: "Only admin can create/update/destroy types!" }
      end
    end
  end
  