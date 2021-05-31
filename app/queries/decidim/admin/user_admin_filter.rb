# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by whitelisted scope or searches on their
    # name
    class UserAdminFilter < Rectify::Query
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - evaluation role to be used as a filter
      def self.for(scope, name_query = nil, search_text = nil, role = nil, current_locale = :ca)
        new(scope, name_query, search_text, role, current_locale).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - users role, must be defined as a scope in the user model
      def initialize(scope, name_query = nil, search_text = nil, role = nil, current_locale = :ca)
        @scope = scope
        @name_query = name_query
        @search_text = search_text
        @role = role
        @current_locale = current_locale
        super
      end

      # List the User groups by the diferents filters.
      def query
        users = scope
        users = filter_by_search(users)
        users = filter_by_search_text(users)
        users = filter_by_role(users)
        Kaminari.paginate_array(users.sort { |u_1, u_2| "#{u_1.active_role}||#{u_1.areas.first&.name}" <=> "#{u_2.active_role}||#{u_2.areas.first&.name}" })
      end

      private

      attr_reader :name_query, :search_text, :role, :scope, :current_locale

      def filter_by_search(users)
        return users if name_query.blank?

        users.where("LOWER(name) LIKE LOWER(?) or LOWER(email) like LOWER(?)", "%#{name_query}%", "%#{name_query}%")
      end

      def filter_by_search_text(users)
        return users if search_text.blank?

        containing_proces_name = "%#{search_text}%"

        query = <<-EOSQL
          (id in (select decidim_user_id
                  from decidim_participatory_process_user_roles
                  where decidim_participatory_process_id in (
                    select id
                    from decidim_participatory_processes
                    where lower(title->>?) like lower(?)))
          or id in  ( select decidim_user_id
                      from decidim_assembly_user_roles
                      where decidim_assembly_id in (
                        select id
                        from decidim_assemblies
                        where lower(title->>?) like lower(?)))
          #{if defined?(Decidim::Conferences)
              "or id in  ( select decidim_user_id
                          from decidim_conference_user_roles
                          where decidim_conference_id in (
                            select id
                            from decidim_conferences
                            where lower(title->>?) like lower(?))))" else ")"
            end}
        EOSQL

        if defined?(Decidim::Conference)
          users.where(query, current_locale, containing_proces_name, current_locale, containing_proces_name, current_locale, containing_proces_name)
        else
          users.where(query, current_locale, containing_proces_name, current_locale, containing_proces_name)
        end
      end

      def filter_by_role(users)
        return users unless Decidim::User::Roles.all.include?(role)

        case role
        when "space_admin"
          if defined?(Decidim::Conferences)
            users.where('"decidim_users"."id" in (select "decidim_participatory_process_user_roles"."decidim_user_id" from "decidim_participatory_process_user_roles")' \
                ' or "decidim_users"."id" in (select "decidim_assembly_user_roles"."decidim_user_id" from "decidim_assembly_user_roles")' \
                ' or "decidim_users"."id" in (select "decidim_conference_user_roles"."decidim_user_id" from "decidim_conference_user_roles")')
          else
            users.where('"decidim_users"."id" in (select "decidim_participatory_process_user_roles"."decidim_user_id" from "decidim_participatory_process_user_roles")' \
                ' or "decidim_users"."id" in (select "decidim_assembly_user_roles"."decidim_user_id" from "decidim_assembly_user_roles")')
          end
        when "admin"
          users.where('"decidim_users"."admin" = ?', true)
        else
          users.where("? = any(roles)", role)
        end
      end
    end
  end
end
