# frozen_string_literal: true

#  NOTE: This module is being override to take into account when a user is a department_admin.

module Decidim
  module Admin
    module UserRolesHelper
      # rubocop: disable Rails/HelperInstanceVariable
      def user_role_config
        return @user_role_config if @user_role_config

        space = current_participatory_space
        @user_role_config = if current_user.admin?
                              space.user_role_config_for(current_user, :organization_admin)
                            elsif current_user.department_admin?
                              space.user_role_config_for(current_user, :department_admin)
                            else
                              role = space.user_roles.find_by(user: current_user)
                              space.user_role_config_for(current_user, role&.role)
                            end
      end
      # rubocop: enable Rails/HelperInstanceVariable
    end
  end
end
