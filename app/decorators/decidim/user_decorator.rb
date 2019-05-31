# frozen_string_literal: true

#
# This decorator adds required associations between Decidim::User and Area.
#

require_dependency 'decidim/user'
Decidim::User.class_eval do
  has_and_belongs_to_many :areas,
                          join_table: :department_admin_areas,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_area_id,
                          validate: false

  scope :admin, -> { where(admin: true) }
  scope :user_manager, -> { where(roles: ["user_manager"]) }
  scope :department_admin, -> { where(roles: ["department_admin"]) }

  def department_admin?
    role?('department_admin')
  end
end
