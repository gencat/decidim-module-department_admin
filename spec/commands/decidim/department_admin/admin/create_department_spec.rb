# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe CreateDepartment do
        subject(:command) { described_class.new(form) }

        let(:organization) { create(:organization) }
        let(:name) { { "en" => "Urbanism", "ca" => "Urbanisme", "es" => "Urbanismo" } }
        let(:form) do
          instance_double(
            DepartmentForm,
            invalid?: invalid,
            name:,
            current_organization: organization
          )
        end
        let(:invalid) { false }

        it "creates the department" do
          expect { command.call }.to broadcast(:ok)
          expect(Department.last.name).to eq(name)
          expect(Department.last.organization).to eq(organization)
        end

        context "when the form is invalid" do
          let(:invalid) { true }

          it "broadcasts invalid and does not create the department" do
            expect { command.call }.not_to change(Department, :count)
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
