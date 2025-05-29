module ApplicationHelper
  include Pagy::Frontend

  def time_duration(seconds)
    return "Unknown" if seconds.blank?

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end
end
