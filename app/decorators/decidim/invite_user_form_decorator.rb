# frozen_string_literal: true

#
# This decorator adds the attribute area_id tot the InviteUserForm and
# extends it with utility methods for the view and command.
#
Decidim::InviteUserForm.class_eval do
  attribute :area_id, Integer

  alias_method :original_roles_method, :available_roles_for_select

  def available_roles_for_select
    if current_user.department_admin?
      Decidim::User::Roles.all.select { |n| n == "department_admin" }.map do |role|
        [
          I18n.t("models.user.fields.roles.#{role}", scope: "decidim.admin"),
          role,
        ]
      end
    else
      original_roles_method
    end
  end

  # called from the view
  def available_areas_for_select
    if current_user.department_admin?
      current_user.areas.collect { |area| [area.translated_name, area.id] }
    else
      Decidim::Area.all.collect { |area| [area.translated_name, area.id] }
    end
  end

  # called from the command
  # returns the selected Decidim::Area instance.
  def selected_area
    Decidim::Area.find_by(id: area_id)
  end
end
