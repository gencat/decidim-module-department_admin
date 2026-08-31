# frozen_string_literal: true

module Decidim::Admin::NewslettersHelperDecorator
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  def self.decorate
    Decidim::Admin::NewslettersHelper.class_eval do
      alias_method :original_spaces_user_can_admin, :spaces_user_can_admin

      def spaces_user_can_admin
        author = current_user

        if author&.department_admin?
          spaces_department_admin_can_admin
        else
          original_spaces_user_can_admin
        end
      end

      def spaces_department_admin_can_admin
        @spaces_user_can_admin ||= {}
        Decidim.participatory_space_manifests.each do |manifest|
          organization_participatory_space(manifest.name)&.each do |space|
            if space.respond_to?(:department)
              next if space.department.blank?
              next unless current_user.departments.include?(space.department)
            elsif space.respond_to?(:decidim_area_id)
              next if space.decidim_area_id.blank?
              next unless current_user.areas.any?
              next unless space.decidim_area_id == current_user.areas.first.id
            else
              next
            end

            @spaces_user_can_admin[manifest.name] ||= []
            space_as_option_for_select_data = space_as_option_for_select(space)
            @spaces_user_can_admin[manifest.name] << space_as_option_for_select_data unless @spaces_user_can_admin[manifest.name].detect do |x|
              x == space_as_option_for_select_data
            end
          end
        end
        @spaces_user_can_admin
      end
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity
end

Decidim::Admin::NewslettersHelperDecorator.decorate
