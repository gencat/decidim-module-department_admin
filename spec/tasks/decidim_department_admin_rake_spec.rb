# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "decidim_department_admin:migrate_areas_to_departments" do
  let(:organization) { create(:organization) }
  let!(:urbanism_area) { create(:area, organization:, name: { "en" => "Urbanism", "ca" => "Urbanisme" }) }
  let!(:culture_area) { create(:area, organization:, name: { "en" => "Culture", "ca" => "Cultura" }) }

  before do
    Decidim::DepartmentAdmin::Engine.load_tasks if Rake::Task.tasks.empty?
  end

  it "creates departments from areas without deleting them" do
    expect do
      Rake::Task["decidim_department_admin:migrate_areas_to_departments"].invoke
    end.to change(Decidim::DepartmentAdmin::Department, :count).by(2)

    expect(Decidim::Area.count).to eq(2)

    dept_1 = Decidim::DepartmentAdmin::Department.find_by(decidim_organization_id: organization.id, name: { "en" => "Urbanism", "ca" => "Urbanisme" })
    expect(dept_1).to be_present

    dept_2 = Decidim::DepartmentAdmin::Department.find_by(decidim_organization_id: organization.id, name: { "en" => "Culture", "ca" => "Cultura" })
    expect(dept_2).to be_present
  end

  it "does not create duplicate departments when run twice" do
    Rake::Task["decidim_department_admin:migrate_areas_to_departments"].invoke
    Rake::Task["decidim_department_admin:migrate_areas_to_departments"].reenable

    expect do
      Rake::Task["decidim_department_admin:migrate_areas_to_departments"].invoke
    end.not_to change(Decidim::DepartmentAdmin::Department, :count)
  end
end
