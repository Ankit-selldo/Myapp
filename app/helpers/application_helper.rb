module ApplicationHelper
  def authenticated?
    user_signed_in?
  end

  def current_cart_items_count
    return 0 unless user_signed_in?
    current_user.cart&.total_items.to_i
  end

  def user_avatar(user, options = {})
    if user.try(:image).try(:attached?)
      image_tag user.image, class: options[:class]
    else
      content_tag :div, class: "#{options[:class]} bg-gray-200 flex items-center justify-center" do
        content_tag :i, nil, class: "fas fa-user text-gray-400"
      end
    end
  end
end
