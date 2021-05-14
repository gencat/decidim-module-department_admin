# frozen_string_literal: true

class AddAreaToConferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_conferences, :decidim_area, index: true if defined?(Decidim::Conferences)
  end
end
