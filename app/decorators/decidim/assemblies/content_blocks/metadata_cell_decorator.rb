# frozen_string_literal: true

module Decidim::Assemblies::ContentBlocks::MetadataCellDecorator
  def metadata_items
    items = super
    items << "department_name" if resource.decidim_department_admin_department_id.present? && items.exclude?("department_name")
    items
  end

  def self.decorate
    Decidim::Assemblies::ContentBlocks::MetadataCell.prepend(self)
  end
end

Decidim::Assemblies::ContentBlocks::MetadataCellDecorator.decorate
