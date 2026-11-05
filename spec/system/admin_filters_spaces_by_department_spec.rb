# frozen_string_literal: true

require "spec_helper"

describe "Admin filters participatory spaces by department" do
  let(:organization) { create(:organization) }
  let!(:health) { create(:department, organization:, name: { en: "Health" }) }
  let!(:education) { create(:department, organization:, name: { en: "Education" }) }
  let!(:culture) { create(:department, organization:, name: { en: "Culture" }) }

  def open_department_filter
    within(".filters__section") do
      find_link("Filter").click
      find_link("Department").click
    end
  end

  def department_options
    within(".filters__section .dropdown .dropdown__right[aria-hidden='false']") do
      all("a").map(&:text)
    end
  end

  def apply_department_filter(name)
    open_department_filter
    within(".filters__section .dropdown .dropdown__right[aria-hidden='false']") do
      click_on(name)
    end
  end

  shared_examples "a list filterable by department" do
    let!(:health_space) { create(factory, organization:, department: health, title: { en: "Health space" }) }
    let!(:education_space) { create(factory, organization:, department: education, title: { en: "Education space" }) }
    let!(:culture_space) { create(factory, organization:, department: culture, title: { en: "Culture space" }) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    context "when the user is an organization admin" do
      let(:user) { create(:user, :admin, :confirmed, organization:) }

      before { visit list_path }

      it "lists all the departments of the organization sorted by name" do
        open_department_filter

        expect(department_options).to eq(%w(Culture Education Health))
      end

      it "does not list departments of other organizations" do
        create(:department, name: { en: "Other organization department" })
        visit list_path
        open_department_filter

        expect(department_options).not_to include("Other organization department")
      end

      it "filters the list by the selected department" do
        apply_department_filter("Education")

        expect(page).to have_content("Education space")
        expect(page).to have_no_content("Health space")
        expect(page).to have_no_content("Culture space")
      end

      it "shows the applied department and allows removing it" do
        apply_department_filter("Education")

        within("[data-applied-filters-tags]") do
          expect(page).to have_content("Department: Education")
        end

        within("[data-applied-filters-tags] .label", text: /Department/) do
          click_on("Cancel")
        end

        expect(page).to have_content("Health space")
        expect(page).to have_content("Education space")
        expect(page).to have_content("Culture space")
      end

      it "follows the departments created and renamed" do
        create(:department, organization:, name: { en: "Agriculture" })
        health.update!(name: { en: "Public health" })
        visit list_path
        open_department_filter

        expect(department_options).to eq(["Agriculture", "Culture", "Education", "Public health"])
      end

      context "when the organization has no departments" do
        let!(:health) { nil }
        let!(:education) { nil }
        let!(:culture) { nil }
        let!(:health_space) { nil }
        let!(:education_space) { nil }
        let!(:culture_space) { nil }

        it "does not show the department filter" do
          within(".filters__section") do
            find_link("Filter").click

            expect(page).to have_no_link("Department")
          end
        end
      end
    end

    context "when the user is a department admin" do
      let(:user) do
        create(:department_admin, :confirmed, organization:, department: health).tap do |department_admin|
          department_admin.departments << education
        end
      end

      before { visit list_path }

      it "lists only the departments of the user" do
        open_department_filter

        expect(department_options).to eq(%w(Education Health))
      end

      it "filters the list by the selected department" do
        apply_department_filter("Health")

        expect(page).to have_content("Health space")
        expect(page).to have_no_content("Education space")
        expect(page).to have_no_content("Culture space")
      end
    end
  end

  context "with participatory processes" do
    let(:factory) { :participatory_process }
    let(:list_path) { decidim_admin_participatory_processes.participatory_processes_path }

    it_behaves_like "a list filterable by department"
  end

  context "with assemblies" do
    let(:factory) { :assembly }
    let(:list_path) { decidim_admin_assemblies.assemblies_path }

    it_behaves_like "a list filterable by department"
  end
end
