class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  private

  # Generic content sanitization method with configurable options
  def sanitize_html_content(content, options = {})
    return content unless content.present?

    default_tags = %w[p br strong em ul ol li h1 h2 h3 h4 h5 h6]
    default_attributes = %w[class]

    ActionController::Base.helpers.sanitize(
      content,
      tags: options[:tags] || default_tags,
      attributes: options[:attributes] || default_attributes
    )
  end

  # Class method to set up content sanitization for specific attributes
  def self.sanitizes(*attributes, **options)
    attributes.each do |attribute|
      before_validation -> { sanitize_attribute(attribute, options) }
    end
  end

  private

  def sanitize_attribute(attribute, options = {})
    current_value = send(attribute)
    if current_value.present?
      sanitized_value = sanitize_html_content(current_value, options)
      send("#{attribute}=", sanitized_value)
    end
  end
end
