# frozen_string_literal: true

module Decidim::Conferences::UpdateConferenceDecorator
  # Saves the Department chosen in the form.
  # Department admins can update any conference without department restriction.
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::UpdateConference.class_eval do
      fetch_form_attributes :title, :slogan, :slug, :weight, :description, :short_description,
                            :objectives, :location, :start_date, :end_date, :promoted, :show_statistics,
                            :taxonomizations, :registrations_enabled, :decidim_department_admin_department_id
    end
  end
end

Decidim::Conferences::UpdateConferenceDecorator.decorate
