# frozen_string_literal: true
class Api::V1::MessagesController < ApplicationController
  before_action :authenticate
  before_action :set_message, only: %i[destroy_message update_message]
  before_action :set_conversation, only: %i[send_message index]
  before_action :set_message, only: %i[update_status get_meesage]

  def send_message
    message = Message.new(message_params)
    message.conversation_id = @conversation.id
    if message.save
      media_url = ""
      media_url = url_for(message.media) if message.media.attached?
      sender = User.find_by_id(message.sender_id)
      receiver = User.find_by_id(message.receiver_id)

      sender_profile_photo = ""
      receiver_profile_photo = ""
      sender_profile_photo = url_for(sender.profile_photo) if sender.profile_photo.attached?
      receiver_profile_photo = url_for(receiver.profile_photo) if receiver.profile_photo.attached?

      if media_url.present?
        render json: { message_id: message.id, conversation_id: @conversation.id, sender_id: message.sender_id, receiver_id: message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, media: media_url, sender_name: sender.name, receiver_name: receiver.name }, status: 200
      else
        render json: { message_id: message.id, conversation_id: @conversation.id, sender_id: message.sender_id, receiver_id: message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, text: message.text, sender_name: sender.name, receiver_name: receiver.name }, status: 200
      end
    else
      render json: message.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_meesage
    media_url = ""
    media_url = url_for(@message.media) if @message.media.attached?
    sender = User.find_by_id(@message.sender_id)
    receiver = User.find_by_id(@message.receiver_id)

    sender_profile_photo = ""
    receiver_profile_photo = ""
    sender_profile_photo = url_for(sender.profile_photo) if sender.profile_photo.attached?
    receiver_profile_photo = url_for(receiver.profile_photo) if receiver.profile_photo.attached?

    if media_url.present?
      render json: { message_id: @message.id, conversation_id: @message.conversation.id, sender_id: @message.sender_id, receiver_id: @message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, media: media_url, sender_name: sender.name, receiver_name: receiver.name }, status: 200
    else
      render json: { message_id: @message.id, conversation_id: @message.conversation.id, sender_id: @message.sender_id, receiver_id: @message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, text: @message.text, sender_name: sender.name, receiver_name: receiver.name }, status: 200
    end
  end

  def update_status
    if params[:status].present?
      @message.update(status: params[:status])
      if @message.errors.any?
        render json: @message.errors.messages, status: 400
      else
        render json: { message: "Message status updated successfully!" }, status: 200
      end
    else
      render json: { message: "please provide status" }, status: 400
    end
  end

  def get_meeages
  end

  def index
    categories = Message.all; all_Categories = []
    messages = @conversation.messages.order("created_at DESC")
    all_messages = []
    messages.each do |message|
      media_url = ""
      media_url = url_for(message.media) if message.media.attached?
      sender = User.find_by_id(message.sender_id)
      receiver = User.find_by_id(message.receiver_id)

      sender_profile_photo = ""
      receiver_profile_photo = ""
      sender_profile_photo = url_for(sender.profile_photo) if sender.profile_photo.attached?
      receiver_profile_photo = url_for(receiver.profile_photo) if receiver.profile_photo.attached?

      if media_url.present?
        all_messages << { message_id: message.id, conversation_id: @conversation.id, sender_id: message.sender_id, receiver_id: message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, media: media_url, sender_name: sender.name, receiver_name: receiver.name }
      else
        all_messages << { message_id: message.id, conversation_id: @conversation.id, sender_id: message.sender_id, receiver_id: message.receiver_id, sender_profile_photo: sender_profile_photo, receiver_profile_photo: receiver_profile_photo, text: message.text, sender_name: sender.name, receiver_name: receiver.name }
      end
    end

    if params[:page].present?
      render json: all_messages.paginate(:page => params[:page], :per_page => 15)
    else
      render json: all_messages.paginate(:page => 1, :per_page => 20)
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_message # instance methode for message
    @message = Message.find_by_id(params[:message_id])
    if @message.present?
      return true
    else
      render json: { message: "message Not found!" }, status: 404
    end
  end

  def set_conversation # instance methode for conversation
    @conversation = Conversation.find_by_id(params[:conversation_id])
    if @conversation.present?
      return true
    else
      render json: { message: "conversation Not found!" }, status: 404
    end
  end

  def message_params
    params.permit(:text, :media, :sender_id, :receiver_id)
  end
end
