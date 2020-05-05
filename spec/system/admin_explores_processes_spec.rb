# frozen_string_literal: true

require 'spec_helper'

describe 'Admin explores processes', type: :system do
  let!(:area) { create(:area) }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "when there are admins of all types" do
    let!(:department_admin) do
      user= create(:user, :confirmed, organization: organization)
      user.roles << 'department_admin'
      user.areas << area
      user.save!
      user
    end
    let!(:process_admin) { create(:user, :user_manager, :confirmed, organization: organization) }

    context "when visiting the list of participatory processes" do
      before do
        visit decidim_admin_participatory_processes.participatory_processes_path
      end

      it "renders a new column for the process department (aka area)" do
        check_column_header_exists(position: 3, content: "DEPARTMENT / AREA")
        check_column_data_exists(position: 3, content: "#{department_admin.name}-#{department_admin.email}")
      end
      it "renders a new column for the department admins in the process"
      it "renders a new column for the process admins in the process"
    end
  end

  def check_column_header_exists(position:1, content:'')
    within "#processes .card-section .table-scroll table thead th:nth-child(#{position})" do
      expect(page).to have_content(content)
    end
  end

  def check_column_data_exists(position:1, content:'')
    within "#processes .card-section .table-scroll table tbody td:nth-child(#{position})" do
      expect(page).to have_content(content)
    end
  end
end
