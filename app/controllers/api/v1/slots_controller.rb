# frozen_string_literal: true
class Api::V1::SlotsController < ApplicationController
  before_action :authenticate
  before_action :set_slot, only: %i[destroy_slot update_slot]

  def create
    slot = Slot.new(slot_params)
    slot.user = @current_user
    if slot.save
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime("%I:%M%p")
      end_time = end_t.strftime("%I:%M%p")
      render json: { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }, status: 200
    else
      render json: slot.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong...#{e} " }, status: :bad_request
  end

  def update_slot
    @slot.update(slot_params)
    @slot.user = @current_user
    if @slot.errors.any?
      render json: @slot.errors.messages, status: 400
    else
      start_t = @slot.start_time
      end_t = @slot.end_time
      start_time = start_t.strftime("%I:%M%p")
      end_time = end_t.strftime("%I:%M%p")
      render json: { slot_id: @slot.id, day: @slot.day, start_time: start_time, end_time: end_time }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def my_slots
    slots = @current_user.slots.uniq { |x| x.day }; all_slots = []
    slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime("%I:%M%p")
      end_time = end_t.strftime("%I:%M%p")
      all_slots << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end
    render json: all_slots, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_slot
    @slot.destroy
    render json: { message: "slot deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_slot # instance methode for slot
    @slot = Slot.find_by_id(params[:slot_id])
    if @slot.present?
      return true
    else
      render json: { message: "slot Not found!" }, status: 404
    end
  end

  def slot_params
    params.permit(:day, :start_time, :end_time)
  end

end
