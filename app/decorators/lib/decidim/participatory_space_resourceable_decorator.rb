# frozen_string_literal: true

module Decidim::ParticipatorySpaceResourceableDecorator
  #
  # This decorator verrided method to avoid .to_sym error when logged in user is Depart Admin
  # Override affects only line `case role_name&.to_sym`
  # Furthermore added new ParticipatorySpaceRole case for DeparmentAdmin
  #
  def self.decorate
    Decidim::ParticipatorySpaceResourceable.class_eval do
      def user_role_config_for(user, role_name)
        case role_name&.to_sym
        when :organization_admin
          Decidim::ParticipatorySpaceRoleConfig::Admin.new(user)
        when :admin # ParticipatorySpace admin
          Decidim::ParticipatorySpaceRoleConfig::ParticipatorySpaceAdmin.new(user)
        when :department_admin
          Decidim::ParticipatorySpaceRoleConfig::DepartmentAdmin.new(user)
        when :valuator
          Decidim::ParticipatorySpaceRoleConfig::Valuator.new(user)
        when :moderator
          Decidim::ParticipatorySpaceRoleConfig::Moderator.new(user)
        when :collaborator
          Decidim::ParticipatorySpaceRoleConfig::Collaborator.new(user)
        else
          Decidim::ParticipatorySpaceRoleConfig::NullObject.new(user)
        end
      end
    end
  end
end

::Decidim::ParticipatorySpaceResourceableDecorator.decorate
