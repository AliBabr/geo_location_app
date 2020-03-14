# frozen_string_literal: true
class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate
  before_action :set_conversation, only: %i[destroy_conversation]
  before_action :check_converstaion, only: %i[connect]

  def connect
    @conversation = check_converstaion
    if @conversation.present?
      set_render
    else
      @conversation = Conversation.find_or_create_by(conversation_params)
      if @conversation.errors.blank?
        set_render
      else
        render json: @conversation.errors.messages, status: 400
      end
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    categories = conversation.all; all_Categories = []
    categories.each do |conversation|
      image_url = ""
      image_url = url_for(conversation.image) if conversation.image.attached?
      all_Categories << { conversation_id: conversation.id, name: conversation.name, color: conversation.color, description: conversation.description, image: image_url }
    end
    render json: all_Categories, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_conversation
    @conversation.destroy
    render json: { message: "conversation deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_conversation # instance methode for conversation
    @conversation = Conversation.find_by_id(params[:conversation_id])
    if @conversation.present?
      return true
    else
      render json: { message: "conversation Not found!" }, status: 404
    end
  end

  def conversation_params
    params.permit(:user_1, :user_2)
  end

  def is_admin
    if @current_user.role == "Admin"
      true
    else
      render json: { message: "Only admin can create/update/destroy Categories!" }
    end
  end

  def check_converstaion
    if params[:user_1].present? && params[:user_2].present?
      conversation1 = Conversation.where(user_1: params[:user_1], user_2: params[:user_2])
      conversation2 = Conversation.where(user_1: params[:user_2], user_2: params[:user_1])
      if conversation1.present?
        @conversation = conversation1.first
      elsif conversation2.present?
        @conversation = conversation2.first
      else
        @conversation = nil
      end
    else
      render json: { message: "Please provide both user_1 & user_2..!" }
    end
  end

  def set_render
    if @conversation.user_1 == @current_user.id
      sender = User.find_by_id(@conversation.user_1)
      receiver = User.find_by_id(@conversation.user_2)
    else
      sender = User.find_by_id(@conversation.user_2)
      receiver = User.find_by_id(@conversation.user_1)
    end
    @conversation_name = receiver.name
    sender_profile_photo = ""
    receiver_profile_photo = ""
    sender_profile_photo = url_for(sender.profile_photo) if sender.profile_photo.attached?
    receiver_profile_photo = url_for(receiver.profile_photo) if receiver.profile_photo.attached?

    render json: { conversation_id: @conversation.id, conversation_name: @conversation_name, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, sender_name: sender.name, receiver_name: receiver.name, sender_id: sender.id, receiver_id: receiver.id }, status: 200
  end
end
