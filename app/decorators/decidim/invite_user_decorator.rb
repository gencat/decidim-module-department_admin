# frozen_string_literal: true

#
# This decorator overwrites how InviteUser performs the invitation by associating the area to the user.
#

Decidim::InviteUser.class_eval do

  def update_user
    raise 'department admin update_user!!!!!!!!'
  end
  def invite_user
    @user = Decidim::User.new(
      name: form.name,
      email: form.email.downcase,
      nickname: Decidim::UserBaseEntity.nicknamize(form.name, organization: form.organization),
      organization: form.organization,
      admin: form.role == "admin",
      roles: form.role == "admin" ? [] : [form.role].compact
    )
    @user.areas << form.selected_area
    @user.invite!(
      form.invited_by,
      invitation_instructions: form.invitation_instructions
    )
  end
end
