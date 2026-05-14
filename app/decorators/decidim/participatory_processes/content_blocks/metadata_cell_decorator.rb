# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCellDecorator
  def self.decorate
    Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCell.class_eval do
      private

      def metadata_items
        super << "department_name" if resource.decidim_department_admin_department_id.present?
      end
    end
  end
end

Decidim::ParticipatoryProcesses::ContentBlocks::MetadataCellDecorator.decorate
