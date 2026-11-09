# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessesWithUserRole do
  subject { described_class.for(user) }

  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:user) { create(:department_admin, :confirmed, organization:, department:) }
  let!(:process) { create(:participatory_process, organization:, department:) }
  let!(:deleted_process) { create(:participatory_process, organization:, department:, deleted_at: Time.current) }
  let!(:other_deleted_process) { create(:participatory_process, organization:, deleted_at: Time.current) }

  it "returns the non deleted processes of the user's departments" do
    expect(subject).to contain_exactly(process)
  end

  it "keeps the deleted processes of the user's departments for the trash" do
    expect(subject.only_deleted).to contain_exactly(deleted_process)
  end
end
