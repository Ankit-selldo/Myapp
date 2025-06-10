# allow_unauthenticated_access # Removed because authenticate is not a global callback anymore

class NewsletterSubscriptionsController < ApplicationController
  def create
    @subscriber = NewsletterSubscriber.new(email: params[:email])

    respond_to do |format|
      if @subscriber.save
        format.html { redirect_back(fallback_location: root_path, notice: 'Successfully subscribed! Please check your email for a welcome message.') }
        format.json { render json: { message: 'Successfully subscribed! Please check your email for a welcome message.' }, status: :ok }
      else
        format.html { redirect_back(fallback_location: root_path, alert: @subscriber.errors.full_messages.join(', ')) }
        format.json { render json: { errors: @subscriber.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
end
