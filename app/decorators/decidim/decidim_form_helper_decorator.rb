# frozen_string_literal: true

module Decidim::DecidimFormHelperDecorator
  #
  # This decorator override Decidim::DecidimFormHelper methods:
  # - areas_for_select with assigned areas to user.
  #
  def self.decorate
    Decidim::DecidimFormHelper.class_eval do
      alias_method :original_areas_for_select, :areas_for_select

      def areas_for_select(organization)
        author = current_user

        return author.areas if author&.department_admin? && controller_path.split("/").include?("admin")

        original_areas_for_select(organization)
      end

      def departments_for_select(organization)
        author = current_user

        return author.departments.map { |d| [translated_attribute(d.name), d.id] } if author&.department_admin? && controller_path.split("/").include?("admin")

        Decidim::DepartmentAdmin::Department
          .where(decidim_organization_id: organization.id)
          .map { |d| [translated_attribute(d.name), d.id] }
      end
    end
  end
end

Decidim::DecidimFormHelperDecorator.decorate
