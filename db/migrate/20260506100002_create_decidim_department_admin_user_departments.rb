# frozen_string_literal: true

class CreateDecidimDepartmentAdminUserDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_department_admin_user_departments do |t|
      t.belongs_to :decidim_user,
                   foreign_key: { to_table: :decidim_users },
                   index: { name: "idx_dept_admin_user_depts_on_user_id" },
                   null: false
      t.belongs_to :decidim_department_admin_department,
                   foreign_key: { to_table: :decidim_department_admin_departments },
                   index: { name: "idx_dept_admin_user_depts_on_department_id" },
                   null: false
    end
  end
end
