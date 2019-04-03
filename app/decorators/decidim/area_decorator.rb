# frozen_string_literal: true

require_dependency 'decidim/area'

Decidim::Area.class_eval do
  before_destroy :abort_if_department_admins

  def has_department_admins?
    Decidim::User.where(organization: organization).any? do |u|
      u.areas.exists?(id)
    end
  end

  def abort_if_department_admins
    throw(:abort) if has_department_admins?
  end
end
