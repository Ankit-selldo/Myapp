# Monkey-patch Array to prevent .permit errors in controllers and Devise
class Array
  def permit(*args)
    Rails.logger.error "[Array#permit PATCH] .permit called on Array! Returning empty ActionController::Parameters. Caller: \\n#{caller.join("\n")}"
    ActionController::Parameters.new
  end
end 