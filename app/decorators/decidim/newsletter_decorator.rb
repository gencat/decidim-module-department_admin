# frozen_string_literal: true

require_dependency "decidim/newsletter"

module Decidim::NewsletterDecorator
  def self.decorate
    Decidim::Newsletter.class_eval do
      # The department of the newsletter is the same
      # than the department of the author of the newsletter.
      # The method name is `department` because the permissions system
      # must verify that the `user` has the same `department` as the `resource`.
      def department
        return unless author.departments.any?

        author.departments.first if author&.department_admin?
      end
    end
  end
end

Decidim::NewsletterDecorator.decorate
