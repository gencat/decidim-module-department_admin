# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCellDecorator
  def metadata_items
    items = super
    items << "department_name" if resource.decidim_department_admin_department_id.present? && items.exclude?("department_name")
    items
  end

  def department_name
    translated_attribute(resource.department.name) if resource.department
  end

  def self.decorate
    Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCell.prepend(self)
  end
end

Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCellDecorator.decorate
