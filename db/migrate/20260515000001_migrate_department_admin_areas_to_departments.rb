# frozen_string_literal: true

class MigrateDepartmentAdminAreasToDepartments < ActiveRecord::Migration[6.1]
  def up
    area_to_dept = build_departments_from_areas
    migrate_users(area_to_dept)
    migrate_assemblies(area_to_dept)
    migrate_participatory_processes(area_to_dept)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # Creates a Department for every existing Area and returns a map area_id => dept_id.
  # All subsequent steps use this map so matching is by ID, not by name (which is a jsonb field).
  def build_departments_from_areas
    area_to_dept = {}
    Decidim::Area.find_each do |area|
      dept = Decidim::DepartmentAdmin::Department.find_or_initialize_by(
        decidim_organization_id: area.decidim_organization_id,
        name: area.name
      )
      dept.save! if dept.new_record?
      area_to_dept[area.id] = dept.id
    end
    area_to_dept
  end

  def migrate_users(area_to_dept)
    Decidim::User.where("'department_admin' = ANY(roles)").find_each do |user|
      execute("SELECT decidim_area_id FROM department_admin_areas WHERE decidim_user_id = #{user.id}").each do |row|
        dept_id = area_to_dept[row["decidim_area_id"].to_i]
        next unless dept_id

        unless execute("SELECT 1 FROM decidim_department_admin_user_departments WHERE decidim_user_id = #{user.id} AND decidim_department_admin_department_id = #{dept_id}").any?
          execute("INSERT INTO decidim_department_admin_user_departments (decidim_user_id, decidim_department_admin_department_id) VALUES (#{user.id}, #{dept_id})")
        end
      end

      execute("DELETE FROM department_admin_areas WHERE decidim_user_id = #{user.id}")
    end
  end

  def migrate_assemblies(area_to_dept)
    Decidim::Assembly.where.not(decidim_area_id: nil).find_each do |assembly|
      dept_id = area_to_dept[assembly.decidim_area_id]
      next unless dept_id

      assembly.update_columns(decidim_department_admin_department_id: dept_id)
    end
  end

  def migrate_participatory_processes(area_to_dept)
    Decidim::ParticipatoryProcess.where.not(decidim_area_id: nil).find_each do |process|
      dept_id = area_to_dept[process.decidim_area_id]
      next unless dept_id

      process.update_columns(decidim_department_admin_department_id: dept_id)
    end
  end
end
