# frozen_string_literal: true
class Api::V1::SlotsController < ApplicationController
  before_action :authenticate
  before_action :set_slot, only: %i[destroy_slot update_slot]
  before_action :set_coach, only: %i[my_slots]


  def create
    slot = Slot.new(slot_params)
    slot.user = @current_user
    if slot.save
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
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
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      render json: { slot_id: @slot.id, day: @slot.day, start_time: start_time, end_time: end_time }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def my_slots
    monday = []; tuesday = []; wednesday = []; thursday = []; friday = []; saturday = []; sunday = [];
    slots = @coach.slots; all_slots = []
    monday_slots = slots.where(day: 'Monday')
    tuesday_slots = slots.where(day: 'Tuesday')
    wednesday_slots = slots.where(day: 'Wednesday')
    thursday_slots = slots.where(day: 'Thursday')
    friday_slots = slots.where(day: 'Friday')
    saturday_slots = slots.where(day: 'Saturday')
    sunday_slots = slots.where(day: 'Sunday')

    monday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      monday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    tuesday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      tuesday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    wednesday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      wednesday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    thursday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      thursday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    friday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      friday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    saturday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      saturday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    sunday_slots.each do |slot|
      start_t = slot.start_time
      end_t = slot.end_time
      start_time = start_t.strftime('%H:%M:%S')
      end_time = end_t.strftime('%H:%M:%S')
      sunday << { slot_id: slot.id, day: slot.day, start_time: start_time, end_time: end_time }
    end

    render json: {monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday}, status: 200
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

  def set_coach # instance methode for category
    @coach = User.find_by_id(params[:coach_id])
    if @coach.present?
      return true
    else
      render json: { message: "Coach Not found!" }, status: 404
    end
  end

end
