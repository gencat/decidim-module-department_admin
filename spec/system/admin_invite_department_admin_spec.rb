# frozen_string_literal: true

require "spec_helper"

describe "Admin invite user as department admin", type: :system do
  let!(:area) { create(:area) }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.new_user_path
  end

  it "admin is successfully created" do
    fill_the_form
    submit_form
    check_department_admin_is_created

    # expect(page).to have_selector ".callout--full"

    # within ".callout--full" do
    #   page.find(".close-button").click
    # end

    # expect(page).to have_content("DASHBOARD")
    # expect(page).to have_current_path "/admin/"
  end

  def fill_the_form
    within "form.new_user" do
      fill_in :user_name, with: "Cabello Loco"
      fill_in :user_email, with: "my@email.net"
      find('#user_role').find("option[value='department_admin']").select_option
    end
  end
  def submit_form
    find("*[name=commit][type=submit]").click
  end
end
