# frozen_string_literal: true

require_dependency 'decidim/newsletter'

Decidim::Newsletter.class_eval do
  def area
    return unless author.areas.any?
    if author&.department_admin?
      return author.areas.first
    end
  end
end
