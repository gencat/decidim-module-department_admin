# frozen_string_literal: true

module Decidim::Conferences::UpdateConferenceDecorator
  def self.decorate
    # intentionally empty: department_admins can update any conference without department restriction
  end
end

Decidim::Conferences::UpdateConferenceDecorator.decorate
