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
    check_succeess
    check_department_admin_is_created
  end

  def fill_the_form
    within "form.new_user" do
      fill_in :user_name, with: "Cabello Loco"
      fill_in :user_email, with: "my@email.net"
      find('#user_role').find("option[value='department_admin']").select_option
      find('#user_area_id').find("option[value='#{area.id}']").select_option
    end
  end
  def submit_form
    find("*[name=commit][type=submit]").click
  end
  def check_succeess(action='invited')
    # expect(page).to have_content("Participant successfully updated.")
    expect(page).to have_content("Participant successfully #{action}.")
    expect(page).to have_current_path "/admin/users"
  end
  def check_department_admin_is_created
    admin= Decidim::User.find_by_email('my@email.net')
    expect(admin.roles).to include('department_admin')
  end
end
