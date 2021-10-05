# frozen_string_literal: true

class AddAreaToConferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_conferences, :decidim_area, index: true if Decidim::DepartmentAdmin.conferences_defined?
  end
end
