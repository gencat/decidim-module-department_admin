# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe UpdateDepartment do
        subject { described_class.new(form, department) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:department) { create(:department, organization:) }
        let(:name) { Decidim::Faker::Localized.literal("New name") }

        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            name:,
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          before do
            subject.call
            department.reload
          end

          it "updates the name of the department" do
            expect(translated(department.name)).to eq("New name")
          end

          it "traces the action", :versioning do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(department, user, hash_including(:name))
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
