# frozen_string_literal: true

module Lib::Decidim::ParticipatorySpaceResourceableDecorator
  #
  # - Add new ParticipatorySpaceRole case for DeparmentAdmin.
  # - Add .to_sym to the `case` test, to avoid error when logged in user is Department Admin
  # This override affects only line `case role_name&.to_sym`
  #
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

require "decidim/assembly"
Decidim::Assembly.prepend(::Lib::Decidim::ParticipatorySpaceResourceableDecorator)
require "decidim/participatory_process"
Decidim::ParticipatoryProcess.prepend(::Lib::Decidim::ParticipatorySpaceResourceableDecorator)
if Decidim::DepartmentAdmin.conferences_defined?
  require "decidim/conference"
  Decidim::Conference.prepend(::Lib::Decidim::ParticipatorySpaceResourceableDecorator)
end
