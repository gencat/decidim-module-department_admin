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
          permission_for?(requested_action, :admin, :read, :admin_dashboard),
          # PARTICIPATORY PROCESSES
          permission_for?(requested_action, :admin, :enter, :space_area, space_name: :processes),
          permission_for?(requested_action, :admin, :read, :process_list),
          # ASSEMBLIES
          permission_for?(requested_action, :admin, :enter, :space_area, space_name: :assemblies),
          permission_for?(requested_action, :admin, :read, :assembly_list),
          permission_for?(requested_action, :admin, :create, :assembly),
          # permission_for?(requested_action, :admin, :update, :assembly, assembly: current_assembly),
          # NEWSLETTER
          permission_for?(requested_action, :admin, :index, :newsletter),
          permission_for?(requested_action, :admin, :read, :newsletter),
          # permission_for?(requested_action, :admin, :read, :newsletter, newsletter: @newsletter),
          permission_for?(requested_action, :admin, :create, :newsletter),
          # permission_for?(requested_action, :admin, :update, :newsletter, newsletter: @newsletter),
          # permission_for?(requested_action, :admin, :destroy, :newsletter, newsletter: @newsletter),
        ].any?
      end

      # Does user have permission for the specified scope/action/subject?
      def permission_for?(requested_action, scope, action, subject, expected_context={})
        is_action?(requested_action, scope, action, subject, expected_context)
      end

      # Is current action requesting permissions for the specified scope/action/subject?
      def is_action?(requested_action, scope, action, subject, expected_context={})
        is= requested_action.matches?(scope, action, subject)
        expected_context.each_pair do |key, expected_value|
          is&&= (context.try(:[], key) == expected_value)
        end
        is
      end
    end
  end
end
