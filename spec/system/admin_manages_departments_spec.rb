# frozen_string_literal: true

require "spec_helper"

describe "Admin manages departments" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "creates and updates a department" do
    visit decidim_admin_department_admin.departments_path

    expect(page).to have_content("Departments")
    click_on "Add"

    fill_in_i18n(
      :department_name,
      "#department-name-tabs",
      en: "Urbanism",
      es: "Urbanismo",
      ca: "Urbanisme"
    )
    click_on "Create"

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_content("Urbanism")

    within "tr", text: "Urbanism" do
      click_on "Edit"
    end

    fill_in_i18n(
      :department_name,
      "#department-name-tabs",
      en: "Culture",
      es: "Cultura",
      ca: "Cultura"
    )
    click_on "Update"

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_content("Culture")
    expect(page).to have_no_content("Urbanism")
  end

  it "does not delete departments assigned to department admins" do
    department = create(:department, organization:, name: { "en" => "Urbanism", "es" => "Urbanismo", "ca" => "Urbanisme" })
    create(:department_admin, :confirmed, organization:, department:)

    visit decidim_admin_department_admin.departments_path

    within "tr", text: "Urbanism" do
      accept_confirm { click_on "Delete" }
    end

    expect(page).to have_content("Cannot delete a department")
    expect(page).to have_content("Urbanism")
  end
end
