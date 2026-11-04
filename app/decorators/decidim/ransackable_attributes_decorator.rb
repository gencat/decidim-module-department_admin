# frozen_string_literal: true

module Decidim::RansackableAttributesDecorator
  #
  # Decidim only allows organization admins to filter and sort by admin attributes (private_space,
  # published_at, process group...). Department admins need them too in the admin spaces lists.
  #
  ADMIN_AUTH_OBJECT = Object.new.tap { |auth_object| auth_object.define_singleton_method(:admin?) { true } }.freeze

  def self.decorate
    models = [Decidim::ParticipatoryProcess, Decidim::Assembly]
    models << Decidim::Conference if Decidim::DepartmentAdmin.conferences_defined?
    models.each do |model|
      model.singleton_class.prepend(self)
    end
  end

  def ransackable_attributes(auth_object = nil)
    return super unless auth_object.try(:department_admin?)

    super(ADMIN_AUTH_OBJECT)
  end
end

Decidim::RansackableAttributesDecorator.decorate
