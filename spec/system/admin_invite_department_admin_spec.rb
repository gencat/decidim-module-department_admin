# frozen_string_literal: true

require "spec_helper"

#
# To "downgrade" an admin to department_admin, it must first be removed from admins
# create a new admin as department_admin.
#
describe "Admin invite user" do
  let(:organization) { create(:organization) }
  let!(:department) { create(:department, organization:) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:user_manager) { create(:user, :user_manager, :confirmed, organization:) }

  let(:department_admin) do
    user = create(:user, :confirmed, organization:)
    user.roles << "department_admin"
    user.departments << department
    user.save!
    user
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.new_user_path
  end

  it "admin is able to create department admins" do
    fill_the_form_for_department_admin("Cabello Loco", "my@email.net")
    submit_form
    check_succeess
    user = check_is_department_admin("my@email.net")
    check_assigned_department(user, department)
  end

  it "admin is able to add department_admin role to existing user" do
    fill_the_form_for_department_admin(user_manager.name, user_manager.email)
    submit_form
    check_succeess
    check_is_department_admin(user_manager.email)
    check_assigned_department(user_manager, department)
  end

  context "when departments are reorganized" do
    let!(:new_department) { create(:department, organization:) }

    before do
      department_admin
      visit decidim_admin.new_user_path
    end

    it "admin is able to change department_admin's area/department" do
      fill_the_form_for_department_admin(department_admin.name, department_admin.email, new_department)
      submit_form
      check_succeess
      check_is_department_admin(department_admin.email)
      check_assigned_department(department_admin, new_department)
    end
  end

  context "when a department_admin is promoted to Admin" do
    it "no longer has the `department_admin` role" do
      department_admin
      fill_the_form_for_admin(department_admin.name, department_admin.email)
      submit_form
      check_succeess
      check_is_admin(department_admin.email)
    end
  end

  def fill_the_form_for_department_admin(name, email, selected_department = department)
    within "form.new_user" do
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      find_by_id("user_role").find("option[value='department_admin']").select_option
      expect(page).to have_css("#user_department_id")
      find_by_id("user_department_id").find("option[value='#{selected_department.id}']").select_option
    end
  end

  def fill_the_form_for_admin(name, email)
    within "form.new_user" do
      fill_in :user_name, with: name
      fill_in :user_email, with: email
      find_by_id("user_role").find("option[value='admin']").select_option
    end
  end

  def submit_form
    find("*[name=commit][type=submit]").click
  end

  def check_succeess
    expect(page).to have_content("Participant successfully invited.")
    expect(page).to have_current_path "/admin/users"
  end

  def check_is_admin(email)
    user = Decidim::User.find_by(email:).reload
    expect(user).to be_admin
    expect(user.roles).not_to include("department_admin")
    expect(user.departments).to be_empty
  end

  def check_is_department_admin(email)
    user = Decidim::User.find_by(email:)
    expect(user.roles).to include("department_admin")
    user
  end

  def check_assigned_department(user, department)
    user.reload
    expect(user.departments.last).to eq(department)
    expect(user.departments.size).to eq(1)
  end
end
