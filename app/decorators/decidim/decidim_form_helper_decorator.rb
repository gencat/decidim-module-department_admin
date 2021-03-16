# frozen_string_literal: true

#
# This decorator override Decidim::DecidimFormHelper methods:
# - areas_for_select with assigned areas to user.
#
Decidim::DecidimFormHelper.class_eval do
  alias_method :original_areas_for_select, :areas_for_select

  def areas_for_select(organization)
    author = current_user

    if author&.department_admin?
      return author.areas if controller_path.split("/").include?("admin")
    end

    original_areas_for_select(organization)
  end
end
