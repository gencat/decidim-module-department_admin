# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by whitelisted scope or searches on their
    # name
    class UserAdminFilter < Rectify::Query
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - evaluation role to be used as a filter
      def self.for(scope, name_query = nil, process_name = nil, role = nil)
        new(scope, name_query, process_name, role).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - users role, must be defined as a scope in the user model
      def initialize(scope, name_query = nil, process_name = nil, role = nil)
        @scope = scope
        @name_query = name_query
        @process_name = process_name
        @role = role
      end

      # List the User groups by the diferents filters.
      def query
        users = scope
        users = filter_by_search(users)
        users = filter_by_process_name(users)
        users = filter_by_role(users)
        Kaminari.paginate_array(users.sort { |u1, u2| "#{u1.active_role}||#{u1.areas.first&.name}" <=> "#{u2.active_role}||#{u2.areas.first&.name}"})
      end

      private

      attr_reader :name_query, :process_name, :role, :scope

      def filter_by_search(users)
        return users if name_query.blank?
        users.where("LOWER(name) LIKE LOWER(?) or LOWER(email) like LOWER(?)", "%#{name_query}%" , "%#{name_query}%")
      end

      def filter_by_process_name(users)
        return users if process_name.blank?
        containing_proces_name= "%#{process_name}%"
        users.where(<<-EOSQL, containing_proces_name, containing_proces_name)
          (id in (select decidim_user_id
                    from decidim_participatory_process_user_roles
                        where decidim_participatory_process_id in (select id
                          from decidim_participatory_processes
                          where lower(title::text) like lower(?)))
                      or id in  ( select decidim_user_id
                      from decidim_assembly_user_roles
                      where decidim_assembly_id in (select id
                        from decidim_assemblies
                        where lower(title::text) like lower(?))))
EOSQL
      end

      def filter_by_role(users)
        return users unless Decidim::User::Roles.all.include?(role)
        if 'space_admin' == role then
          users.where('"decidim_users"."id" in (select "decidim_participatory_process_user_roles"."decidim_user_id" from "decidim_participatory_process_user_roles")' +
               ' or "decidim_users"."id" in (select "decidim_assembly_user_roles"."decidim_user_id" from "decidim_assembly_user_roles")')
        elsif 'admin' == role then
          users.where('"decidim_users"."admin" = ?', true)
        else
          users.where("? = any(roles)", role)
        end
      end
    end
  end
end
