# frozen_string_literal: true

class AddDecidimDepartmentAdminDepartmentIdToParticipatoryProcesses < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_processes, :decidim_department_admin_department_id, :bigint, null: true
    add_index :decidim_participatory_processes, :decidim_department_admin_department_id, name: "idx_processes_on_decidim_department_admin_department_id"
  end
end
