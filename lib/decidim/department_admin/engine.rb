# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DepartmentAdmin
    # This is the engine that runs on the public interface of department_admin.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DepartmentAdmin

      # make decorators autoload in development env
      config.autoload_paths << File.join(
        Decidim::DepartmentAdmin::Engine.root, "app", "decorators", "{**}"
      )

      config.to_prepare do
        # activate Decidim LayoutHelper for the overriden views
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
      end

      routes do
        # Add engine routes here
        # resources :department_admin
        # root to: "department_admin#index"
      end

      # rubocop: disable Lint/ConstantDefinitionInBlock
      initializer "department_admin.permissions_registry" do
        # activate Decidim LayoutHelper for the overriden views
        # TO-DO remove the to_prepare "ActiveSupport.on_load :action_controller" that doesn't work for the test env??
        ::Decidim::Admin::ApplicationController.helper ::Decidim::LayoutHelper

        # avoid webpacker to crash when executing before Decidim is loaded
        next unless Rails.env.test? || defined? DecidimController

        # **
        # Modify decidim-admin permissions registry
        # **
        artifact = ::Decidim::Admin::ApplicationController
        AdminApplicationControllerPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
        register_new_permissions_for(artifact, AdminApplicationControllerPermissions)

        # **
        # Modify decidim-particypatory_processes permissions registry
        # **

        # force the concern to be included so that registry is initialized
        # we choose some random class already including it
        require "decidim/participatory_processes/admin/categories_controller"
        artifact = ::Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin
        ParticipatoryProcessesAdminConcernPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
        register_new_permissions_for(artifact, ParticipatoryProcessesAdminConcernPermissions)

        artifact = Decidim::ParticipatoryProcesses::Admin::ApplicationController
        ParticipatoryProcessesAdminApplicationControllerPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
        register_new_permissions_for(artifact, ParticipatoryProcessesAdminApplicationControllerPermissions)

        # public views produce problems with Devise's current_user
        # require 'decidim/participatory_processes/application_controller'
        # artifact= 'Decidim::ParticipatoryProcesses::ApplicationController'
        # chain= ::Decidim.permissions_registry.chain_for(artifact)
        # chain << ::Decidim::DepartmentAdmin::Permissions

        # **
        # Modify decidim-assemblies permissions registry
        # **
        require "decidim/assemblies/admin/assembly_copies_controller"
        require "decidim/assemblies/admin/components_controller"
        artifact = ::Decidim::Assemblies::Admin::Concerns::AssemblyAdmin
        AssembliesAdminConcernPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
        register_new_permissions_for(artifact, AssembliesAdminConcernPermissions)

        artifact = Decidim::Assemblies::Admin::ApplicationController
        AssembliesAdminApplicationControllerPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
        register_new_permissions_for(artifact, AssembliesAdminApplicationControllerPermissions)

        if Decidim::DepartmentAdmin.conferences_defined?
          # **
          # Modify decidim-conferences permissions registry
          # **
          require "decidim/conferences/admin/conference_copies_controller"
          require "decidim/conferences/admin/components_controller"
          artifact = ::Decidim::Conferences::Admin::Concerns::ConferenceAdmin
          ConferencesAdminConcernPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
          register_new_permissions_for(artifact, ConferencesAdminConcernPermissions)

          artifact = Decidim::Conferences::Admin::ApplicationController
          ConferencesAdminApplicationControllerPermissions = Class.new(::Decidim::DepartmentAdmin::Permissions)
          register_new_permissions_for(artifact, ConferencesAdminApplicationControllerPermissions)
        end
      end
      # rubocop: enable Lint/ConstantDefinitionInBlock

      initializer "department_admin.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        decorators = "#{Decidim::DepartmentAdmin::Engine.root}/app/decorators"
        # Rails.autoloaders.main.ignore(decorators)
        Dir.glob("#{decorators}/**/*_decorator.rb").each do |decorator|
          load decorator
        end
      end

      config.after_initialize do
        require "decidim/participatory_processes/participatory_space"
        # override participatory_processes space manifest permissions with DepartmentAdmin's one
        manifest = Decidim.find_participatory_space_manifest(:participatory_processes)
        manifest.permissions_class_name = "Decidim::ParticipatoryProcesses::ParticipatorySpacePermissions"
        # override assemblies space manifest permissions with DepartmentAdmin's one
        manifest = Decidim.find_participatory_space_manifest(:assemblies)
        manifest.permissions_class_name = "Decidim::Assemblies::ParticipatorySpacePermissions"
        if Decidim::DepartmentAdmin.conferences_defined?
          # override conferences space manifest permissions with DepartmentAdmin's one
          manifest = Decidim.find_participatory_space_manifest(:conferences)
          manifest.permissions_class_name = "Decidim::Conferences::ParticipatorySpacePermissions"
        end
      end

      #------------------------------------------------------

      private

      #------------------------------------------------------

      # Modifies the permissions registry for the given +artifact+ with +new_permissions_class+.
      # NOTE: Previous permissions are cleared and setted to the +new_permissions_class+ for delegation.
      def register_new_permissions_for(artifact, new_permissions_class)
        chain = ::Decidim.permissions_registry.chain_for(artifact)
        # configure old chain, in case new permissions has to delegate
        new_permissions_class.delegate_chain = chain.dup
        # re-set the permissions classes to DepartmentAdmin::Permissions' subclass
        chain.clear
        chain << new_permissions_class
        Rails.logger.info("Registered new permissions for #{artifact} to: #{::Decidim.permissions_registry.chain_for(artifact)}")
      end
    end
  end
end
