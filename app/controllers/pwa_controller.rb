# allow_unauthenticated_access # Removed because authenticate is not a global callback anymore
class PwaController < ApplicationController
  include Devise::Controllers::Helpers # Explicitly include Devise helpers
  
  # Reverted to using skip_before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:manifest, :service_worker]
  skip_before_action :verify_authenticity_token, only: [:service_worker]

  def manifest
    render json: {
      name: "My App",
      short_name: "My App",
      start_url: "/",
      display: "standalone",
      background_color: "#ffffff",
      theme_color: "#000000",
      icons: [
        {
          src: "/icons/icon.svg",
          sizes: "any",
          type: "image/svg+xml",
          purpose: "any"
        },
        {
          src: "/icons/icon-192x192.png",
          sizes: "192x192",
          type: "image/png",
          purpose: "any"
        },
        {
          src: "/icons/icon-512x512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "any"
        }
      ]
    }
  end

  def service_worker
    render file: Rails.root.join('public/service-worker.js')
  end

  def offline
    render layout: false
  end
end 