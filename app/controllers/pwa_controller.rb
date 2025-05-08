class PwaController < ApplicationController
  allow_unauthenticated_access
  protect_from_forgery with: :exception, except: [:manifest, :service_worker]

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