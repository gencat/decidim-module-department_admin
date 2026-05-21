# frozen_string_literal: true

require "spec_helper"

describe "Public participatory spaces show departments" do
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:, name: { "en" => "Urbanism", "ca" => "Urbanisme", "es" => "Urbanismo" }) }

  before do
    switch_to_host(organization.host)
  end

  it "shows a participatory process department in metadata" do
    process = create(:participatory_process, :published, organization:, department:)
    create(:content_block,
           organization:,
           scope_name: :participatory_process_homepage,
           manifest_name: :metadata,
           scoped_resource_id: process.id,
           published_at: Time.current)

    visit decidim_participatory_processes.participatory_process_path(process)

    within ".participatory-space__metadata-grid" do
      expect(page).to have_content("DEPARTMENT")
      expect(page).to have_content("Urbanism")
    end
  end

  it "shows an assembly department in metadata" do
    assembly = create(:assembly, :published, organization:, department:)
    create(:content_block,
           organization:,
           scope_name: :assembly_homepage,
           manifest_name: :metadata,
           scoped_resource_id: assembly.id,
           published_at: Time.current)

    visit decidim_assemblies.assembly_path(assembly)

    within ".participatory-space__metadata-grid" do
      expect(page).to have_content("DEPARTMENT")
      expect(page).to have_content("Urbanism")
    end
  end
end
