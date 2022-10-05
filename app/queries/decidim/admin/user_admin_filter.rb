# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by whitelisted scope or searches on their
    # name
    class UserAdminFilter < Rectify::Query
      # scope - the ActiveRecord::Relation of users to be filtered
      # termsc - text to filter users by
      # role - evaluation role to be used as a filter
      def self.for(scope, term = nil, role = nil, organization = nil)
        new(scope, term, role, organization).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # term - text to filter users by name or email
      # role - users role, must be defined as a scope in the user model
      def initialize(scope, term = nil, role = nil, organization = nil)
        @scope = scope
        @term = term
        @role = role
        @organization = organization
        super(scope)
      end

      def query
        filter_by_role(scope)
      end

      private

      attr_reader :term, :role, :scope

      def filter_by_role(users)
        case role
        when "space_admin"
          Decidim::User.space_admins(@organization)
        when "admin"
          users.where('"decidim_users"."admin" = ?', true)
        when "department_admin", "user_manager"
          users.where("? = any(roles)", role)
        else
          users.or(Decidim::User.space_admins(@organization))
        end
      end
    end
  end
end
