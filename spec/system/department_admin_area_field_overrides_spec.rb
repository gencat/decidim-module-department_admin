# frozen_string_literal: true

require "spec_helper"

describe "Department admin area field overrides" do
  let(:area) { create(:area, organization:) }
  let(:organization) { create(:organization) }
  let(:department_admin) do
    user = create(:user, :confirmed, organization:)
    user.roles << "department_admin"
    user.areas << area
    user.save!
    user
  end

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  describe "participatory processes form" do
    before do
      visit decidim_admin.new_participatory_processes_path
    end

    it "shows area field as disabled with department admin area pre-selected" do
      within ".new_participatory_process" do
        area_select = find("#participatory_process_area_id")

        expect(area_select).to be_present
        expect(area_select[:disabled]).to eq("true")
        expect(area_select.value).to eq(area.id.to_s)
      end
    end

    it "creates participatory process with department admin area when form is submitted" do
      within ".new_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Test Process",
          es: "Proceso de Prueba"
        )
        fill_in_i18n(
          :participatory_process_subtitle,
          "#participatory_process-subtitle-tabs",
          en: "Subtitle",
          es: "Subtitulo"
        )
        fill_in_i18n_editor(
          :participatory_process_short_description,
          "#participatory_process-short_description-tabs",
          en: "Short description",
          es: "Descripcion corta"
        )
        fill_in_i18n_editor(
          :participatory_process_description,
          "#participatory_process-description-tabs",
          en: "A longer description",
          es: "Descripcion mas larga"
        )
        fill_in :participatory_process_slug, with: "test-process"

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      created_process = Decidim::ParticipatoryProcess.last
      expect(created_process.area).to eq(area)
    end
  end

  describe "assemblies form" do
    before do
      visit decidim_admin.assemblies_path
      click_on "New assembly"
    end

    it "shows area field as disabled with department admin area pre-selected" do
      within ".new_assembly" do
        area_select = find("#assembly_area_id")

        expect(area_select).to be_present
        expect(area_select[:disabled]).to eq("true")
        expect(area_select.value).to eq(area.id.to_s)
      end
    end

    it "creates assembly with department admin area when form is submitted" do
      attributes = attributes_for(:assembly, organization:)

      within ".new_assembly" do
        fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:assembly_subtitle, "#assembly-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:assembly_short_description, "#assembly-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_description, "#assembly-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_purpose_of_action, "#assembly-purpose_of_action-tabs", **attributes[:purpose_of_action].except("machine_translations"))
        fill_in_i18n_editor(:assembly_composition, "#assembly-composition-tabs", **attributes[:composition].except("machine_translations"))
        fill_in_i18n_editor(:assembly_internal_organisation, "#assembly-internal_organisation-tabs", **attributes[:internal_organisation].except("machine_translations"))

        fill_in_i18n(:assembly_participatory_scope, "#assembly-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:assembly_participatory_structure, "#assembly-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))
        fill_in_i18n(:assembly_meta_scope, "#assembly-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:assembly_local_area, "#assembly-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:assembly_target, "#assembly-target-tabs", **attributes[:target].except("machine_translations"))

        fill_in :assembly_slug, with: "test-assembly"
        fill_in :assembly_weight, with: 1

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      created_assembly = Decidim::Assembly.last
      expect(created_assembly.area).to eq(area)
    end
  end
end
