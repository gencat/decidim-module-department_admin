# frozen_string_literal: true

class CreateDecidimDepartmentAdminDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_department_admin_departments do |t|
      t.jsonb :name, null: false, default: {}
      t.belongs_to :decidim_organization, foreign_key: { to_table: :decidim_organizations }, null: false,
                                          index: { name: "idx_dept_admin_departments_on_org_id" }

      t.timestamps
    end
  end
end
