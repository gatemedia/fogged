# frozen_string_literal: true
class ImagesControllers < ApplicationController
  def index
    render json: Image.all
  end
end
