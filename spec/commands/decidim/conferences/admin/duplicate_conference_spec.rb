# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::DuplicateConference do
    subject { described_class.new(form, conference) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :admin, organization:) }
    let(:department) { create(:department, organization:) }
    let!(:conference) { create(:conference, organization:, decidim_department_admin_department_id: department.id) }
    let(:form) do
      instance_double(
        Admin::ConferenceDuplicateForm,
        invalid?: false,
        title: { en: "title" },
        slug: "duplicated-slug",
        duplicate_components?: false,
        current_user:
      )
    end

    it "keeps the department in the duplicated conference" do
      expect { subject.call }.to broadcast(:ok)

      duplicated = Decidim::Conference.find_by(slug: "duplicated-slug")
      expect(duplicated.department).to eq(department)
    end

    context "when the conference has no department" do
      let!(:conference) { create(:conference, organization:) }

      it "duplicates it without department" do
        expect { subject.call }.to broadcast(:ok)

        expect(Decidim::Conference.find_by(slug: "duplicated-slug").department).to be_nil
      end
    end
  end
end
