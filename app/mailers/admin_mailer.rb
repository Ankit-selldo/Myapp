class AdminMailer < ApplicationMailer
  def low_stock_notification(product_variant)
    @variant = product_variant
    @product = product_variant.product
    
    mail(
      to: Rails.application.credentials.admin_email,
      subject: "Low Stock Alert - #{@product.name} (#{@variant.color}/#{@variant.size})"
    )
  end
end 