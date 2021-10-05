# frozen_string_literal: true

#
# This decorator adds required associations between Decidim::User and Area.
#

require_dependency "decidim/user"
Decidim::User.class_eval do
  has_and_belongs_to_many :areas,
                          join_table: :department_admin_areas,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_area_id,
                          validate: false

  has_and_belongs_to_many :participatory_processes,
                          join_table: :decidim_participatory_process_user_roles,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_participatory_process_id,
                          validate: false

  has_and_belongs_to_many :assemblies,
                          join_table: :decidim_assembly_user_roles,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_assembly_id,
                          validate: false
  if Decidim::DepartmentAdmin.conferences_defined?
    has_and_belongs_to_many :conferences,
                            join_table: :decidim_conference_user_roles,
                            foreign_key: :decidim_user_id,
                            association_foreign_key: :decidim_conference_id,
                            validate: false
  end

  scope :admins, -> { where(admin: true) }
  scope :user_managers, -> { where(roles: ["user_manager"]) }
  scope :department_admins, -> { where(roles: ["department_admin"]) }

  def department_admin?
    role?("department_admin")
  end
end
