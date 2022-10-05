# frozen_string_literal: true

require_dependency "decidim/newsletter"

module Decidim::NewsletterDecorator
  def self.decorate
    Decidim::Newsletter.class_eval do
      # The area of the newsletter is the same
      # than the area of the author of the newsletter.
      # The method name is `area` because the permissions system
      # must verify that the `user` has the same `area` as the `resource`.
      def area
        return unless author.areas.any?
        return author.areas.first if author&.department_admin?
      end
    end
  end
end

::Decidim::NewsletterDecorator.decorate
