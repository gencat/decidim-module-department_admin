# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    class Department < ApplicationRecord
      include Traceable
      include Loggable
      include Decidim::TranslatableResource

      translatable_fields :name

      belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :departments

      has_and_belongs_to_many :users,
                              -> { where("'department_admin'=ANY(\"decidim_users\".\"roles\")") },
                              class_name: "Decidim::User",
                              join_table: :department_admin_user_departments,
                              foreign_key: :department_admin_department_id,
                              association_foreign_key: :decidim_user_id,
                              validate: false

      validates :name, presence: true, uniqueness: { scope: :organization }

      before_destroy :abort_if_dependencies

      def self.log_presenter_class_for(_log)
        Decidim::AdminLog::DepartmentPresenter
      end

      def translated_name
        Decidim::DepartmentPresenter.new(self).translated_name
      end

      def has_dependencies?
        Decidim.participatory_space_registry.manifests.any? do |manifest|
          manifest
            .participatory_spaces
            .call(organization)
            .any? do |space|
            space.respond_to?(:department) && space.decidim_department_id == id
          end
        end
      end

      # used on before_destroy
      def abort_if_dependencies
        throw(:abort) if has_dependencies?
      end
    end
  end
end
