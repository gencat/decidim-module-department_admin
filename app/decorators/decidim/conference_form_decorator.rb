# frozen_string_literal: true

#
# This decorator adds the attribute area_id to the ConferenceForm and
# extends it with utility methods for the view and command.
#
if defined?(Decidim::Conference)
  Decidim::Conferences::Admin::ConferenceForm.class_eval do
    attribute :area_id, Integer

    validates :area, presence: true, if: proc { |object| object.area_id.present? }

    def area
      @area ||= current_organization.areas.find_by(id: area_id)
    end
  end
end
