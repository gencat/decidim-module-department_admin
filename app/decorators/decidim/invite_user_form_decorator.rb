# frozen_string_literal: true

#
# This decorator adds the attribute area_id tot the InviteUserForm and
# extends it with utility methods for the view and command.
#
Decidim::InviteUserForm.class_eval do
  attribute :area_id, Integer

  # called from the view
  def available_areas_for_select
    Decidim::Area.all.collect { |area| [area.translated_name, area.id] }
  end

  # called from the command
  # returns the selected Decidim::Area instance.
  def selected_area
    Decidim::Area.find_by(id: area_id)
  end
end
