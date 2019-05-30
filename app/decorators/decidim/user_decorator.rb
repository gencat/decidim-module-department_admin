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

  def department_admin?
    role?('department_admin')
  end
end
