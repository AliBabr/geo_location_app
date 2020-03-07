# frozen_string_literal: true
class Api::V1::NewsController < ApplicationController
  before_action :authenticate
  before_action :set_news, only: %i[destroy_news update_news get_news]

  def create
    news = News.new(news_params)
    if news.save
      if params[:video].present?
        news_video = NewsVideo.new(news_video_params)
        news_video.news_id = news.id
        news_video.save
      end
      image_url = ""
      image_url = url_for(news.image) if news.image.attached?
      video = ""
      if news.news_video.present?
        video = url_for(news.news_video.video) if news.news_video.video.attached?
      end
      render json: { news_id: news.id, title: news.title, full_text: news.full_text, news_type: news.news_type, post_url: news.post_url, image: image_url, video: video }, status: 200
    else
      render json: news.errors.messages, status: 400
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def update_news
    @news.update(news_params)
    if params[:video].present? && @news.news_video.present?
      @news.news_video.update(news_video_params)
    end
    if @news.errors.any?
      render json: @news.errors.messages, status: 400
    else
      image_url = ""
      image_url = url_for(@news.image) if @news.image.attached?
      video = ""
      if @news.news_video.present?
        video = url_for(@news.news_video.video) if @news.news_video.video.attached?
      end
      render json: { news_id: @news.id, title: @news.title, full_text: @news.full_text, news_type: @news.news_type, post_url: @news.post_url, image: image_url, video: video }, status: 200
    end
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def index
    get_news = News.all; all_news = []
    get_news.each do |news|
      image_url = ""
      image_url = url_for(news.image) if news.image.attached?
      video = ""
      if news.news_video.present?
        video = url_for(news.news_video.video) if news.news_video.video.attached?
      end
      all_news << { news_id: news.id, title: news.title, full_text: news.full_text, news_type: news.news_type, post_url: news.post_url, image: image_url, video: video }
    end
    render json: all_news, status: 200
  rescue StandardError => e
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def destroy_news
    @news.destroy
    render json: { message: "news deleted successfully!" }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  def get_news
    image_url = ""
    image_url = url_for(@news.image) if @news.image.attached?
    video = ""
    if @news.news_video.present?
      video = url_for(@news.news_video.video) if @news.news_video.video.attached?
    end
    render json: { news_id: @news.id, title: @news.title, full_text: @news.full_text, news_type: @news.news_type, post_url: @news.post_url, image: image_url, video: video }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: "Error: Something went wrong... " }, status: :bad_request
  end

  private

  def set_news # instance methode for news
    @news = News.find_by_id(params[:news_id])
    if @news.present?
      return true
    else
      render json: { message: "news Not found!" }, status: 404
    end
  end

  def news_params
    params.permit(:title, :full_text, :news_type, :post_url, :image)
  end

  def news_video_params
    params.permit(:video)
  end
end
