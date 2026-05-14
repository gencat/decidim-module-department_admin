# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe DestroyDepartment do
        subject(:command) { described_class.new(department, current_user) }

        let!(:department) { create(:department) }
        let(:current_user) { create(:user, :admin, :confirmed, organization: department.organization) }

        it "destroys the department" do
          expect { command.call }.to broadcast(:ok)
          expect { Department.find(department.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "when department admins are assigned" do
          before do
            create(:department_admin, :confirmed, organization: department.organization, department:)
          end

          it "broadcasts that the department has department admins" do
            expect { command.call }.to broadcast(:has_department_admins)
            expect(department.reload).to be_present
          end
        end
      end
    end
  end
end
