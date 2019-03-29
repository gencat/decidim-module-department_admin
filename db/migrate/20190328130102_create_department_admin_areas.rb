class CreateDepartmentAdminAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :department_admin_areas do |t|
      t.belongs_to :decidim_user, foreign_key: true
      t.belongs_to :decidim_area, foreign_key: true
    end
  end
end
