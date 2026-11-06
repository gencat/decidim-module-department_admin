# frozen_string_literal: true

module Decidim::RansackableAttributesDecorator
  #
  # Decidim only allows organization admins to filter and sort by admin attributes (private_space,
  # published_at, process group...). Department admins need them too in the admin spaces lists.
  #
  # It also allows organization admins and department admins to filter processes and assemblies
  # by department, used by the "Department" option of the admin lists "Filter" dropdown.
  #
  ADMIN_AUTH_OBJECT = Object.new.tap { |auth_object| auth_object.define_singleton_method(:admin?) { true } }.freeze
  DEPARTMENT_ATTRIBUTE = "decidim_department_admin_department_id"

  def self.decorate
    models = [Decidim::ParticipatoryProcess, Decidim::Assembly]
    models << Decidim::Conference if Decidim::DepartmentAdmin.conferences_defined?
    models.each do |model|
      model.singleton_class.prepend(self)
    end
  end

  def ransackable_attributes(auth_object = nil)
    attributes = auth_object.try(:department_admin?) ? super(ADMIN_AUTH_OBJECT) : super
    return attributes unless filterable_by_department?(auth_object)

    attributes + [DEPARTMENT_ATTRIBUTE]
  end

  private

  def filterable_by_department?(auth_object)
    return false unless [Decidim::ParticipatoryProcess, Decidim::Assembly].include?(self)

    auth_object.try(:admin?) || auth_object.try(:department_admin?)
  end
end

Decidim::RansackableAttributesDecorator.decorate
