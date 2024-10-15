# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UsersController do
    # routes { Decidim::Core::Engine.routes }
    routes { Decidim::Admin::Engine.routes }

    let!(:admin_user) { create(:user, :admin, :confirmed) }
    let!(:current_user) { admin_user }
    let(:organization) { admin_user.organization }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in current_user, scope: :user
    end

    describe "role filter" do
      let!(:participant) { create(:user, :confirmed, organization:) }
      let!(:department_admin_user) { create(:department_admin, :confirmed, organization:) }
      let!(:user_manager) { create(:user, :confirmed, organization:, roles: ["user_manager"]) }
      let!(:process_admin) { create(:user, :confirmed, organization:) }
      let!(:participatory_process) { create(:participatory_process, organization:, title: { en: "A Process space" }) }
      let!(:process_admin_rel) { Decidim::ParticipatoryProcessUserRole.create(role: "admin", user: process_admin, participatory_process:) }
      let!(:assembly_admin) { create(:user, :confirmed, organization:) }
      let!(:assembly) { create(:assembly, organization:, title: { en: "An Assembly space" }) }
      let!(:assembly_admin_rel) { Decidim::AssemblyUserRole.create(role: "admin", user: assembly_admin, assembly:) }

      subject { controller.filtered_collection }

      context "when not filtering" do
        it "lists all kind of admin users" do
          get :index, params: {}

          expect(subject).to include(admin_user, department_admin_user, user_manager, assembly_admin, process_admin)
          expect(subject).not_to include(participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by process admin email in user term" do
        it "lists the process admin user" do
          get :index, params: { q: { name_or_nickname_or_email_cont: process_admin.email.split("@").first } }

          expect(subject).to include(process_admin)
          expect(subject).not_to include(admin_user, department_admin_user, user_manager, assembly_admin, participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by space name" do
        it "lists the space_admins in spaces matching the given term" do
          get :index, params: { q: { name_or_nickname_or_email_cont: "space" }, filter_search: "by_process_name" }

          expect(subject).to include(process_admin, assembly_admin)
          expect(subject).not_to include(admin_user, department_admin_user, user_manager, participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by admin role" do
        let(:params) do
          { role: "admin" }
        end

        it "lists only users with role admin" do
          get(:index, params:)

          expect(subject).to include(admin_user)
          expect(subject).not_to include(department_admin_user, user_manager, process_admin, assembly_admin, participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by department_admin role" do
        let(:params) do
          { role: "department_admin" }
        end

        it "lists only users with role department_admin" do
          get(:index, params:)

          expect(subject).to include(department_admin_user)
          expect(subject).not_to include(admin_user, user_manager, process_admin, assembly_admin, participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by user_manager role" do
        let(:params) do
          { role: "user_manager" }
        end

        it "lists only users with role user_manager" do
          get(:index, params:)

          expect(subject).to include(user_manager)
          expect(subject).not_to include(admin_user, department_admin_user, process_admin, assembly_admin, participant)
          expect(response).to render_template(:index)
        end
      end

      context "when filtering by space_admin role" do
        let(:params) do
          { role: "space_admin" }
        end

        it "lists only users with role space_admin" do
          get(:index, params:)

          expect(subject).to include(process_admin, assembly_admin)
          expect(subject).not_to include(admin_user, department_admin_user, user_manager, participant)
          expect(response).to render_template(:index)
        end
      end
    end
  end
end
