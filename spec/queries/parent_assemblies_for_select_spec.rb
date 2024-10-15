# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe ParentAssembliesForSelect do
    subject { described_class.for(organization, assembly) }

    let(:organization) { create(:organization) }
    let!(:assembly) { create(:assembly, organization:) }
    let!(:assemblies) { create_list(:assembly, 3, organization:) }
    let!(:child_assembly) { create(:assembly, :with_parent, parent: assembly, organization:) }
    let!(:grand_child_assembly) { create(:assembly, :with_parent, parent: child_assembly, organization:) }

    describe "query" do
      context "when current_user is nil" do
        it "returns assemblies that can be parent" do
          expect(subject.count).to eq(3)
          expect(subject).to match_array(assemblies)
        end
      end

      context "when current_user is present" do
        subject { described_class.for(organization, assembly, current_user) }

        let!(:current_user) do
          create(:department_admin, :confirmed, organization: area.organization, area:)
        end
        let(:area) { create(:area) }
        let!(:assemblies_with_area) { create_list(:assembly, 3, organization:, area:) }

        it "returns assemblies that can be parent with same current user area" do
          expect(subject.count).to eq(3)
          expect(subject).to match_array(assemblies_with_area)
        end
      end

      context "when assembly is nil" do
        let(:assembly) { nil }

        it "returns all assemblies" do
          expected = assemblies
          expected << child_assembly
          expected << grand_child_assembly

          expect(subject.count).to eq(5)
          expect(subject).to match_array(expected)
        end
      end
    end
  end
end
