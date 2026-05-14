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

    visit decidim_participatory_processes.participatory_process_path(process)

    within ".definition-data__item.department" do
      expect(page).to have_content("Department")
      expect(page).to have_content("Urbanism")
    end
  end

  it "shows an assembly department in metadata" do
    assembly = create(:assembly, :published, organization:, department:)

    visit decidim_assemblies.assembly_path(assembly)

    within ".definition-data__item.department" do
      expect(page).to have_content("Department")
      expect(page).to have_content("Urbanism")
    end
  end
end
