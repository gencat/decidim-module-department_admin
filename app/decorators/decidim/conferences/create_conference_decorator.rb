# frozen_string_literal: true

# Forces the Area of the user if it is a department_admin user.
module Decidim::Conferences::CreateConferenceDecorator
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::CreateConference.class_eval do
      fetch_form_attributes :organization, :title, :slogan, :slug, :weight, :hashtag, :description,
                      :short_description, :objectives, :location, :taxonomizations, :start_date, :end_date,
                      :promoted, :show_statistics, :registrations_enabled, :available_slots, :registration_terms,
                      :area


      def run_before_hooks
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
      end
    end
  end
end

Decidim::Conferences::CreateConferenceDecorator.decorate
