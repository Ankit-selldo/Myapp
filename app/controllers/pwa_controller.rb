class PwaController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token, only: [:manifest, :service_worker]

  def manifest
    render formats: :json
  end

  def service_worker
    render formats: :js, content_type: "application/javascript"
  end

  def offline
    render layout: false
  end
end 