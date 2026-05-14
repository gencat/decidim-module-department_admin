# frozen_string_literal: true

module Decidim::InviteUserDecorator
  #
  # This decorator overwrites how InviteUser performs the invitation by associating the department to the user.
  #
  def self.decorate
    Decidim::InviteUser.class_eval do
      alias_method :original_update_user, :update_user

      def update_user
        add_selected_department_to(user)
        clear_department_admin_role if admin_role?
        original_update_user
      end

      def invite_user
        @user = Decidim::User.new(
          name: form.name,
          email: form.email.downcase,
          nickname: Decidim::UserBaseEntity.nicknamize(form.name, form.organization.id),
          organization: form.organization,
          admin: admin_role?,
          roles: admin_role? ? [] : [form.role].compact
        )
        add_selected_department_to(@user)
        @user.invite!(
          form.invited_by,
          invitation_instructions: form.invitation_instructions
        )
      end

      private #---------------------------------------------------------

      def add_selected_department_to(user)
        if current_user.department_admin?
          user.departments << current_user.departments.first
        elsif form.selected_department.present?
          user.departments.clear
          user.departments << form.selected_department
        end
      end

      def admin_role?
        form.role == "admin"
      end

      def clear_department_admin_role
        user.departments.clear
        user.roles.delete("department_admin")
      end
    end
  end
end

Decidim::InviteUserDecorator.decorate

