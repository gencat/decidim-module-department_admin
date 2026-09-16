# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    module Admin
      describe DestroyDepartment do
        subject { described_class.new(department, user) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:department) { create(:department, organization:) }

        it "destroys the department" do
          subject.call
          expect { department.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "broadcasts ok" do
          expect do
            subject.call
          end.to broadcast(:ok)
        end

        it "traces the action", :versioning do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:delete, department, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
