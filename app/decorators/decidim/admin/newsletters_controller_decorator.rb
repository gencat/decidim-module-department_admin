# frozen_string_literal: true

require_dependency "decidim/admin/newsletters_controller"

# Sort Admins by role and area
::Decidim::Admin::NewslettersController.class_eval do
  alias_method :original_collection, :collection

  private

  def collection
    return original_collection unless current_user.department_admin?

    @collection ||= Decidim::Newsletter.where(organization: current_organization)
                                       .joins(author: :areas)
                                       .where("department_admin_areas.decidim_area_id = ?", current_user_areas.pluck(:id))
  end

  def current_user_areas
    return unless current_user.department_admin?

    current_user.areas
  end
end
