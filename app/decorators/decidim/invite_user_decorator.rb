# frozen_string_literal: true

#
# This decorator overwrites how InviteUser performs the invitation by associating the area to the user.
#

Decidim::InviteUser.class_eval do
  alias_method :original_update_user, :update_user

  def update_user
    add_selected_area_to(user)
    clear_department_admin_role if admin_role?
    original_update_user
  end

  def invite_user
    @user = Decidim::User.new(
      name: form.name,
      email: form.email.downcase,
      nickname: Decidim::UserBaseEntity.nicknamize(form.name, organization: form.organization),
      organization: form.organization,
      admin: admin_role?,
      roles: admin_role? ? [] : [form.role].compact
    )
    add_selected_area_to(@user)
    @user.invite!(
      form.invited_by,
      invitation_instructions: form.invitation_instructions
    )
  end

  private #---------------------------------------------------------

  def add_selected_area_to(user)
    if form.selected_area.present?
      user.areas.clear
      user.areas << form.selected_area
    end
  end

  def admin_role?
    form.role == 'admin'
  end

  def clear_department_admin_role
    user.areas.clear
    user.roles.delete('department_admin')
  end
end
