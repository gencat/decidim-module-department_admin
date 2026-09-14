# frozen_string_literal: true

class AddDecidimDepartmentAdminDepartmentIdToConferences < ActiveRecord::Migration[7.0]
  def change
    return unless Decidim::DepartmentAdmin.conferences_defined?

    add_column :decidim_conferences, :decidim_department_admin_department_id, :bigint, null: true
    add_index :decidim_conferences, :decidim_department_admin_department_id, name: "idx_conferences_on_decidim_department_admin_department_id"
  end
end
