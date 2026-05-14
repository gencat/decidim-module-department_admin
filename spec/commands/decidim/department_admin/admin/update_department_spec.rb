# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe UpdateDepartment do
        subject(:command) { described_class.new(department, form) }

        let(:department) { create(:department) }
        let(:name) { { "en" => "Culture", "ca" => "Cultura", "es" => "Cultura" } }
        let(:form) { instance_double(DepartmentForm, invalid?: invalid, name:) }
        let(:invalid) { false }

        it "updates the department" do
          expect { command.call }.to broadcast(:ok)
          expect(department.reload.name).to eq(name)
        end

        context "when the form is invalid" do
          let(:invalid) { true }

          it "broadcasts invalid and does not update the department" do
            expect { command.call }.to broadcast(:invalid)
            expect(department.reload.name).not_to eq(name)
          end
        end
      end
    end
  end
end
