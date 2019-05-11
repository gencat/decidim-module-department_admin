# frozen_string_literal: true

#
# This decorator extends Decidim::User with:
# - the new role in ROLES, and
# - adds required associations between User and Area.
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
require 'fiddle'

class Object
  def unfreeze
    Fiddle::Pointer.new(object_id * 2)[1] &= ~(1 << 3)
  end
end
Decidim::User::ROLES.unfreeze
Decidim::User::ROLES << 'department_admin'
