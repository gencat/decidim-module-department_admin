# frozen_string_literal: true

module Decidim::OrganizationDecorator
  def self.decorate
    Decidim::Organization.class_eval do
      has_many :departments, -> { order(name: :asc) }, foreign_key: "decidim_organization_id", class_name: "Decidim::DepartmentAdmin::Department", inverse_of: :organization, dependent: :destroy
    end
  end
end

Decidim::OrganizationDecorator.decorate
