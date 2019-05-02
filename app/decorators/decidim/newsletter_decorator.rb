# frozen_string_literal: true

require_dependency 'decidim/newsletter'

Decidim::Newsletter.class_eval do
  def area
    return unless author.areas.any?
    return author.areas.first if author&.department_admin?
  end
end
