# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    class Permissions < Decidim::DefaultPermissions

      def self.delegate_chain=(chain)
        @delegate_chain= chain
      end
      def self.delegate_chain
        @delegate_chain
      end
      def delegate_chain
        self.class.delegate_chain
      end

      def permissions
        puts "EXECUTING PERMISSIONS FOR #{permission_action.inspect} WITH CONTEXT [#{context}] IN #{self}"
        puts "USER: #{user} > #{user.roles}"

        current_permission_action= if user && user.role?("department_admin")
          puts "APLYING DepartmentAdmin permissions"
          # avoid having PermissionCannotBeDisallowedError if permission was already disallowed in the chain
          new_permission_action= permission_action.dup
          if has_permission?(new_permission_action)
            puts "ALLOWING: #{new_permission_action}"
            new_permission_action.allow!
            new_permission_action
          else
            permission_action
          end
        elsif self.delegate_chain.present?
          puts "APLYING delegate chain permissions"
          delegate_chain.inject(permission_action) do |injected_permission_action, permission_class|
            puts "Delegating to: #{permission_class}"
            permission_class.new(user, injected_permission_action, context).permissions
          end.allowed?
          permission_action
        else
          puts "APLYING default permissions"
          super
        end
        puts "returning...."
        return current_permission_action
      end

      def has_permission?(requested_action)
        [
          -> { permission_for?(requested_action, :admin, :read, :admin_dashboard) },

          # PARTICIPATORY PROCESSES
          -> {permission_for_current_space?(requested_action)},
          -> {permission_for?(requested_action, :admin, :enter, :space_area, space_name: :processes)},
          -> {permission_for?(requested_action, :admin, :read, :process_list)},
          -> {permission_for?(requested_action, :admin, :create, :process)},
          -> {same_area_permission_for?(requested_action, :admin, :update, :process, restricted_rsrc: context[:process])},
          -> {same_area_permission_for?(requested_action, :admin, :destroy, :process, restricted_rsrc: context[:process])},
          -> {permission_for?(requested_action, :admin, :read, :process_step)},
          -> {permission_for?(requested_action, :admin, :create, :process_step)},
          -> {same_area_permission_for?(requested_action, :admin, :update, :process_step, restricted_rsrc: context[:process_step]&.participatory_process)},
          -> {same_area_permission_for?(requested_action, :admin, :destroy, :process_step, restricted_rsrc: context[:process_step]&.participatory_process)},
          # copy
          # enforce_permission_to :create, Decidim::ParticipatoryProcess

          # ASSEMBLIES
          -> {permission_for?(requested_action, :admin, :enter, :space_area, space_name: :assemblies)},
          -> {permission_for?(requested_action, :admin, :read, :assembly_list)},
          -> {permission_for?(requested_action, :admin, :create, :assembly)},
          -> {same_area_permission_for?(requested_action, :admin, :update, :assembly, restricted_rsrc: context[:assembly])},

          # NEWSLETTER
          -> {permission_for?(requested_action, :admin, :index, :newsletter)},
          -> {permission_for?(requested_action, :admin, :read, :newsletter, restricted_rsrc: context[:newsletter])},
          -> {permission_for?(requested_action, :admin, :create, :newsletter)},
          -> {same_area_permission_for?(requested_action, :admin, :update, :newsletter, restricted_rsrc: context[:newsletter])},
          -> {same_area_permission_for?(requested_action, :admin, :destroy, :newsletter, restricted_rsrc: context[:newsletter])},
        ].any? {|block| block.call}
      end

      ALLOWED_SPACES= ['Decidim::ParticipatoryProcess']
      def permission_for_current_space?(permission_action)
        has= permission_for?(permission_action, :admin, :read, :participatory_space)
        has&&= ALLOWED_SPACES.include?(context[:current_participatory_space].class.name)
        has
      end

      # Does user have permission for the specified scope/action/subject?
      def permission_for?(requested_action, scope, action, subject, expected_context={})
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
      def is_action?(requested_action, scope, action, subject, expected_context={})
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
