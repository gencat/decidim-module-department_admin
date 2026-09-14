# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class MigrateDepartmentAdminConferenceAreasToDepartments < ActiveRecord::Migration[7.0]
  def up
    return unless Decidim::DepartmentAdmin.conferences_defined?

    migrate_conferences(build_departments_from_areas)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # Creates a Department for every Area used by a Conference (reusing one that
  # might already exist for that Area, e.g. created by the assemblies/processes
  # migration) and returns a map area_id => dept_id.
  def build_departments_from_areas
    area_to_dept = {}
    area_ids = Decidim::Conference.where.not(decidim_area_id: nil).distinct.pluck(:decidim_area_id)
    Decidim::Area.where(id: area_ids).find_each do |area|
      dept = Decidim::DepartmentAdmin::Department.find_or_initialize_by(
        decidim_organization_id: area.decidim_organization_id,
        name: area.name
      )
      dept.save! if dept.new_record?
      area_to_dept[area.id] = dept.id
    end
    area_to_dept
  end

  def migrate_conferences(area_to_dept)
    Decidim::Conference.where.not(decidim_area_id: nil).find_each do |conference|
      dept_id = area_to_dept[conference.decidim_area_id]
      next unless dept_id

      conference.update_columns(decidim_department_admin_department_id: dept_id)
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
