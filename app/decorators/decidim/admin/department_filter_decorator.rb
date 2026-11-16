# frozen_string_literal: true

module Decidim::Admin::DepartmentFilterDecorator
  #
  # This decorator adds a "Department" option to the "Filter" dropdown of the
  # participatory processes and assemblies admin lists.
  #
  # The departments are queried on every request, so the options follow the
  # departments created, renamed or removed. Organization admins get all the
  # departments of the organization, department admins only their own ones.
  #
  FILTER = :decidim_department_admin_department_id_eq

  def self.decorate
    [
      Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController,
      Decidim::Assemblies::Admin::AssembliesController,
    ].each do |controller|
      controller.prepend(self)
    end
  end

  private

  def filters
    return super if filterable_departments.empty?

    super + [FILTER]
  end

  def filters_with_values
    return super if filterable_departments.empty?

    super.merge(FILTER => filterable_departments.map(&:id))
  end

  def dynamically_translated_filters
    super + [FILTER]
  end

  def translated_decidim_department_admin_department_id_eq(id)
    translated_attribute(filterable_departments.find { |department| department.id == id.to_i }&.name)
  end

  def filterable_departments
    @filterable_departments ||= begin
      departments = Decidim::DepartmentAdmin::Department.where(organization: current_organization)
      departments = departments.where(id: current_user.departments) unless current_user.admin?
      departments.sort_by { |department| I18n.transliterate(translated_attribute(department.name).to_s).downcase }
    end
  end
end

Decidim::Admin::DepartmentFilterDecorator.decorate
