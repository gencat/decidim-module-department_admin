# frozen_string_literal: true

#
# This decorator overwrites how InviteUser performs the invitation by associating the area to the user.
#

Decidim::InviteUser.class_eval do
  alias_method :original_update_user, :update_user

  alias_method :original_update_user, :update_user

  def update_user
    add_selected_area_to(user)
    original_update_user
  end

  def invite_user
    @user = Decidim::User.new(
      name: form.name,
      email: form.email.downcase,
      nickname: Decidim::UserBaseEntity.nicknamize(form.name, organization: form.organization),
      organization: form.organization,
      admin: form.role == 'admin',
      roles: admin_role? ? [] : [form.role].compact
    )
    add_selected_area_to(@user)
    @user.invite!(
      form.invited_by,
      invitation_instructions: form.invitation_instructions
    )
  end

  #---------------------------------------------------------
  private
  #---------------------------------------------------------

  def add_selected_area_to(user)
    user.areas << form.selected_area if form.selected_area.present?
  end

  def admin_role?
    form.role == 'admin'
  end
end
