# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe CreateDepartment do
        subject { described_class.new(form) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:name) { Decidim::Faker::Localized.literal(::Faker::Address.unique.state) }

        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            name:,
            organization:,
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
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "creates a new department for the organization" do
            expect { subject.call }.to change { organization.departments.count }.by(1)
          end

          it "traces the action", :versioning do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Decidim::DepartmentAdmin::Department, user, hash_including(:name, :organization))
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
