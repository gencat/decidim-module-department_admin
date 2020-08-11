# frozen_string_literal: true

module Decidim
  module Admin
    module UserRolesHelper
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
    end
  end
end
