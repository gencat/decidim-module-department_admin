# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcess do
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, department:) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:admin_attributes) { %w(private_space published_at decidim_participatory_process_group_id) }

  describe ".ransackable_attributes" do
    it "includes admin attributes for department admins" do
      expect(described_class.ransackable_attributes(department_admin)).to include(*admin_attributes)
    end

    it "does not include admin attributes for regular users" do
      expect(described_class.ransackable_attributes(user)).not_to include(*admin_attributes)
      expect(described_class.ransackable_attributes).not_to include(*admin_attributes)
    end
  end

  describe "department attribute" do
    let(:admin) { create(:user, :admin, :confirmed, organization:) }
    let(:department_attribute) { "decidim_department_admin_department_id" }

    it "is included for organization admins" do
      expect(described_class.ransackable_attributes(admin)).to include(department_attribute)
    end

    it "is included for department admins" do
      expect(described_class.ransackable_attributes(department_admin)).to include(department_attribute)
    end

    it "is not included for regular users nor visitors" do
      expect(described_class.ransackable_attributes(user)).not_to include(department_attribute)
      expect(described_class.ransackable_attributes).not_to include(department_attribute)
    end
  end
end
