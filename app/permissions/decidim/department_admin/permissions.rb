# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    class Permissions < Decidim::DefaultPermissions
      class << self
        attr_writer :delegate_chain
      end

      class << self
        attr_reader :delegate_chain
      end

      def delegate_chain
        self.class.delegate_chain
      end

      def permissions
        current_permission_action= permission_action
        if permission_action.scope == :admin && user&.department_admin?
          current_permission_action= apply_department_admin_permissions!
        elsif delegate_chain.present?
          delegate_chain.inject(permission_action) do |injected_permission_action, permission_class|
            permission_class.new(user, injected_permission_action, context).permissions
          end
        else
          super
        end

        current_permission_action
      end

      def apply_department_admin_permissions!
        # avoid having PermissionCannotBeDisallowedError if permission was already disallowed in the chain
        new_permission_action= permission_action.dup
        if has_permission?(new_permission_action)
         new_permission_action.allow!
         new_permission_action
        else
         permission_action
        end
      end

      def has_permission?(requested_action)
        [
          -> { permission_for?(requested_action, :admin, :read, :admin_dashboard) },
          -> { permission_for?(requested_action, :public, :read, :admin_dashboard) },

          # PARTICIPATORY PROCESSES
          -> { permission_for_current_space?(requested_action) },
          -> { permission_for?(requested_action, :admin, :enter, :space_area, space_name: :processes) },
          -> { permission_for?(requested_action, :admin, :read, :process_list) },
          -> { permission_for?(requested_action, :admin, :create, :process) },
          -> { same_area_permission_for?(requested_action, :admin, :preview, :process, restricted_rsrc: context[:process]) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :process, restricted_rsrc: context[:process]) },
          -> { same_area_permission_for?(requested_action, :admin, :publish, :process, restricted_rsrc: context[:process]) },
          -> { same_area_permission_for?(requested_action, :admin, :unpublish, :process, restricted_rsrc: context[:process]) },
          # STEPS
          -> { permission_for?(requested_action, :admin, :read, :process_step) },
          -> { permission_for?(requested_action, :admin, :create, :process_step) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :process_step, restricted_rsrc: context[:process_step]&.participatory_process) },
          -> { same_area_permission_for?(requested_action, :admin, :activate, :process_step, restricted_rsrc: context[:process_step]&.participatory_process) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :process_step, restricted_rsrc: context[:process_step]&.participatory_process) },
          # COMPONENTS
          -> { permission_for?(requested_action, :admin, :read, :component) },
          -> { permission_for?(requested_action, :admin, :create, :component) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :component, restricted_rsrc: context[:component]&.participatory_space) },
          -> { same_area_permission_for?(requested_action, :admin, :manage, :component, restricted_rsrc: context[:component]&.participatory_space) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :component, restricted_rsrc: context[:component]&.participatory_space) },
          -> { same_area_permission_for?(requested_action, :admin, :publish, :component, restricted_rsrc: context[:component]&.participatory_space) },
          -> { same_area_permission_for?(requested_action, :admin, :unpublish, :component, restricted_rsrc: context[:component]&.participatory_space) },
          # CATEGORIES
          -> { permission_for?(requested_action, :admin, :read, :category) },
          -> { permission_for?(requested_action, :admin, :create, :category) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :category, restricted_rsrc: context[:category]&.participatory_space) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :category, restricted_rsrc: context[:category]&.participatory_space) },
          # ATTACHMENT COLLECTIONS
          -> { permission_for?(requested_action, :admin, :read, :attachment_collection) },
          -> { permission_for?(requested_action, :admin, :create, :attachment_collection) },
          -> { same_area_permission_for?(requested_action, :admin, :read, :attachment_collection, restricted_rsrc: context[:attachment_collection]&.collection_for) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :attachment_collection, restricted_rsrc: context[:attachment_collection]&.collection_for) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :attachment_collection, restricted_rsrc: context[:attachment_collection]&.collection_for) },
          # ATTACHMENTS
          -> { permission_for?(requested_action, :admin, :read, :attachment) },
          -> { permission_for?(requested_action, :admin, :create, :attachment) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :attachment, restricted_rsrc: context[:attachment]&.attached_to) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :attachment, restricted_rsrc: context[:attachment]&.attached_to) },
          # INVITE PROCESS ADMIN: USER ROLES
          -> { permission_for?(requested_action, :admin, :read, :process_user_role) },
          -> { permission_for?(requested_action, :admin, :create, :process_user_role) },
          -> { permission_for?(requested_action, :admin, :update, :process_user_role) },
          -> { permission_for?(requested_action, :admin, :destroy, :process_user_role) },
          # SPACE PRIVATE USERS
          -> { permission_for?(requested_action, :admin, :read, :space_private_user) },
          -> { permission_for?(requested_action, :admin, :create, :space_private_user) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :space_private_user, restricted_rsrc: context[:private_user]&.privatable_to) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :space_private_user, restricted_rsrc: context[:private_user]&.privatable_to) },
          -> { same_area_permission_for?(requested_action, :admin, :invite, :space_private_user, restricted_rsrc: context[:private_user]&.privatable_to) },
          # MODERATIONS
          -> { permission_for?(requested_action, :admin, :read, :moderation) },
          -> { permission_for?(requested_action, :admin, :unreport, :moderation) },
          -> { permission_for?(requested_action, :admin, :hide, :moderation) },
          -> { permission_for?(requested_action, :admin, :unhide, :moderation) },

          # ASSEMBLIES
          -> { permission_for?(requested_action, :admin, :enter, :space_area, space_name: :assemblies) },
          -> { permission_for?(requested_action, :admin, :read, :assembly_list) },
          -> { permission_for?(requested_action, :admin, :create, :assembly) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :assembly, restricted_rsrc: context[:assembly]) },
          -> { same_area_permission_for?(requested_action, :admin, :publish, :assembly, restricted_rsrc: context[:assembly]) },
          -> { same_area_permission_for?(requested_action, :admin, :unpublish, :assembly, restricted_rsrc: context[:assembly]) },
          # Assembly Members
          -> { same_area_permission_for?(requested_action, :admin, :read, :assembly_member, restricted_rsrc: context[:assembly]) },
          # other assembly_member permissions are setted via Decidim::Assemblies::AssembliesWithUserRole decorator

          # NEWSLETTER
          -> { permission_for?(requested_action, :admin, :index, :newsletter) },
          -> { permission_for?(requested_action, :admin, :read, :newsletter) },
          -> { permission_for?(requested_action, :admin, :create, :newsletter) },
          -> { same_area_permission_for?(requested_action, :admin, :update, :newsletter, restricted_rsrc: context[:newsletter]) },
          -> { same_area_permission_for?(requested_action, :admin, :destroy, :newsletter, restricted_rsrc: context[:newsletter]) }
        ].any?(&:call)
      end

      ALLOWED_SPACES= ['Decidim::ParticipatoryProcess', 'Decidim::Assembly'].freeze
      def permission_for_current_space?(permission_action)
        has= permission_for?(permission_action, :admin, :read, :participatory_space)
        has||= permission_for?(permission_action, :public, :read, :participatory_space)
        has&&= ALLOWED_SPACES.include?(context[:current_participatory_space].class.name)
        has
      end

      # Does user have permission for the specified scope/action/subject?
      def permission_for?(requested_action, scope, action, subject, expected_context = {})
        is_action?(requested_action, scope, action, subject, expected_context)
      end

      # Does user have permission for the specified scope/action/subject?
      # Also check if the resource in the context for with the key defined by `area_restricted_rsrc`
      # has the same area as current user.
      def same_area_permission_for?(requested_action, scope, action, subject, restricted_rsrc:)
        is= is_action?(requested_action, scope, action, subject)
        is&&= in_same_area?(restricted_rsrc)
        is
      end

      # Is current action requesting permissions for the specified scope/action/subject?
      def is_action?(requested_action, scope, action, subject, expected_context = {})
        is= requested_action.matches?(scope, action, subject)
        expected_context.each_pair do |key, expected_value|
          is&&= (context.try(:[], key) == expected_value)
        end
        is
      end

      def in_same_area?(resource)
        user.areas.include? resource.area
      end
    end
  end
end
