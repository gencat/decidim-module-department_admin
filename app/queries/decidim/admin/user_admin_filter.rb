# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to filter users by whitelisted scope or searches on their
    # name
    class UserAdminFilter < Rectify::Query
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - evaluation role to be used as a filter
      def self.for(scope, name_query = nil, role = nil)
        new(scope, name_query, role).query
      end

      # Initializes the class.
      #
      # scope - the ActiveRecord::Relation of users to be filtered
      # name_query - query to filter user group names
      # role - users role, must be defined as a scope in the user model
      def initialize(scope, name_query = nil, role = nil)
        @scope = scope
        @name_query = name_query
        @role = role
      end

      # List the User groups by the diferents filters.
      def query
        users = scope
        users = filter_by_search(users)
        users = filter_by_role(users)
        Kaminari.paginate_array(users.sort { |u1, u2| "#{u1.active_role}||#{u1.areas.first&.name}" <=> "#{u2.active_role}||#{u2.areas.first&.name}"})
      end

      private

      attr_reader :name_query, :role, :scope

      def filter_by_search(users)
        return users if name_query.blank?
        users.where("LOWER(name) LIKE LOWER(?)", "%#{name_query}%")
      end

      def filter_by_role(users)
        return users unless Decidim::User::Roles.all.include?(role)
        users.public_send(role.pluralize)
      end
    end
  end
end
