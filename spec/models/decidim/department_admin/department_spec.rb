# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    describe Department do
      subject(:department) { create(:department, organization:) }

      let(:organization) { create(:organization) }

      context "when depending participatory process exist" do
        let!(:department_admin) do
          user = create(:user, :confirmed, organization: department.organization)
          user.roles << "department_admin"
          user.departments << department
          user.save!
          user
        end

        it "can not be deleted" do
          expect(department.destroy).to be false
        end
      end
    end
  end
end
