# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    describe Department do
      subject(:department) { create(:department) }

      it "is valid" do
        expect(department).to be_valid
      end

      context "when department admins are assigned" do
        before do
          create(:department_admin, :confirmed, organization: department.organization, department:)
        end

        it "can not be deleted" do
          expect(department.destroy).to be false
        end
      end
    end
  end
end
