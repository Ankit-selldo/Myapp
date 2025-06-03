class ErrorsController < ApplicationController
  # remove the conditional authenticate_user! as it's handled in ApplicationController
  # skip_before_action :authenticate_user!, only: [:not_found, :internal_server_error, :unprocessable_entity]

  def not_found
    respond_to do |format|
      format.html { render file: Rails.root.join('public/404.html'), status: :not_found, layout: false }
      format.json { render json: { error: 'Not found' }, status: :not_found }
      # Add a fallback for all other formats
      format.all { render file: Rails.root.join('public/404.html'), status: :not_found, layout: false }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render file: Rails.root.join('public/500.html'), status: :internal_server_error, layout: false }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
      # Add a fallback for all other formats
      format.all { render file: Rails.root.join('public/500.html'), status: :internal_server_error, layout: false }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render file: Rails.root.join('public/422.html'), status: :unprocessable_entity, layout: false }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
      # Add a fallback for all other formats
      format.all { render file: Rails.root.join('public/422.html'), status: :unprocessable_entity, layout: false }
    end
  end
end 