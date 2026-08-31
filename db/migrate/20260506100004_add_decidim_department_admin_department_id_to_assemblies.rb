# frozen_string_literal: true

class AddDecidimDepartmentAdminDepartmentIdToAssemblies < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_assemblies, :decidim_department_admin_department_id, :bigint, null: true
    add_index :decidim_assemblies, :decidim_department_admin_department_id, name: "idx_assemblies_on_decidim_department_admin_department_id"
  end
end
