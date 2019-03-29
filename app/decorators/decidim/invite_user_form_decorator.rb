# frozen_string_literal: true

# A form object used to invite users to an organization.
#
Decidim::InviteUserForm.class_eval do
  attribute :area_id, Integer

  def available_areas_for_select
    Decidim::Area.all.collect { |area| [area.translated_name, area.id] }
  end

  # returns the selected Decidim::Area instance.
  def selected_area
    Decidim::Area.find(area_id)
  end
end
