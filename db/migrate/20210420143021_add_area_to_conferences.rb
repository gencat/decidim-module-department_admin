class AddAreaToConferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_conferences, :decidim_area, index: true
  end
end
