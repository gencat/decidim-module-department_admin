# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    module Admin
      class DepartmentForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :name, String
        attribute :organization, Decidim::Organization

        validates :name, translatable_presence: true
        validates :organization, presence: true

        alias organization current_organization
      end
    end
  end
end
