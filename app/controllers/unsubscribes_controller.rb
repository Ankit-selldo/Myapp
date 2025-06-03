# allow_unauthenticated_access # Removed because authenticate is not a global callback anymore
class UnsubscribesController < ApplicationController
  before_action :set_subscriber

  def show
    @subscriber&.destroy
    redirect_to root_path, notice: "Unsubscribed successfully."
  end

  private

  def set_subscriber
    @subscriber = Subscriber.find_by_token_for(:unsubscribe, params[:token])
  end
end
