# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by processes that hey administer
    class UserAdminBySpaceNameFilter < Rectify::Query
      # termsc - text to filter users by
      def self.for(term = nil, organization = nil, current_locale = :ca)
        new(term, organization, current_locale).query
      end

      # Initializes the class.
      #
      # term - text to filter users by name or email
      def initialize(term = nil, organization = nil, current_locale = :ca)
        @term = term
        @organization = organization
        @current_locale = current_locale
        super(Decidim::User.space_admins(@organization))
      end

      def query
        filter_by_processes_term
      end

      private

      attr_reader :term, :current_locale

      def filter_by_processes_term
        return @scope if term.blank?

        containing_space_name = "%#{term}%"

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
          #{if Decidim::DepartmentAdmin.conferences_defined?
              "or id in  ( select decidim_user_id
                          from decidim_conference_user_roles
                          where decidim_conference_id in (
                            select id
                            from decidim_conferences
                            where lower(title->>?) like lower(?))))" else ")"
            end}
        EOSQL

        if Decidim::DepartmentAdmin.conferences_defined?
          @scope.where(query, current_locale, containing_space_name, current_locale, containing_space_name, current_locale, containing_space_name)
        else
          @scope.where(query, current_locale, containing_space_name, current_locale, containing_space_name)
        end
      end
    end
  end
end
