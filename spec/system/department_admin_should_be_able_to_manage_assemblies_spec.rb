# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", :versioning do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  shared_examples "creating an assembly" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }
    let(:attributes) { attributes_for(:assembly, organization:) }

    before do
      visit decidim_admin_assemblies.assemblies_path
      click_link_or_button "New assembly"
    end

    it "creates a new assembly" do
      within ".new_assembly" do
        fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:assembly_subtitle, "#assembly-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:assembly_short_description, "#assembly-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_description, "#assembly-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_purpose_of_action, "#assembly-purpose_of_action-tabs", **attributes[:purpose_of_action].except("machine_translations"))
        fill_in_i18n_editor(:assembly_composition, "#assembly-composition-tabs", **attributes[:composition].except("machine_translations"))
        fill_in_i18n_editor(:assembly_internal_organisation, "#assembly-internal_organisation-tabs", **attributes[:internal_organisation].except("machine_translations"))
        fill_in_i18n_editor(:assembly_announcement, "#assembly-announcement-tabs", **attributes[:announcement].except("machine_translations"))
        fill_in_i18n_editor(:assembly_closing_date_reason, "#assembly-closing_date_reason-tabs", **attributes[:closing_date_reason].except("machine_translations"))

        fill_in_i18n(:assembly_participatory_scope, "#assembly-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:assembly_participatory_structure, "#assembly-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))
        fill_in_i18n(:assembly_meta_scope, "#assembly-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:assembly_local_area, "#assembly-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:assembly_target, "#assembly-target-tabs", **attributes[:target].except("machine_translations"))

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        fill_in :assembly_weight, with: 1
      end

      dynamically_attach_file(:assembly_hero_image, image1_path)
      dynamically_attach_file(:assembly_banner_image, image2_path)

      within ".new_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(Decidim::Assembly.last.area).to eq(area)

      within ".container" do
        # expect(page).to have_current_path decidim_admin_assemblies.assemblies_path(q: { parent_id_eq: parent_assembly&.id })
        expect(page).to have_content(translated(attributes[:title]))
      end
    end
  end

  context "when managing parent assemblies" do
    let(:parent_assembly) { nil }
    let!(:assembly) { create(:assembly, organization:) }

    before do
      switch_to_host(organization.host)
      login_as department_admin, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    # it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
  end

  context "when managing child assemblies" do
    let!(:parent_assembly) { create(:assembly, organization:, area:) }
    let!(:child_assembly) { create(:assembly, organization:, parent: parent_assembly, area:) }
    let(:assembly) { child_assembly }

    before do
      switch_to_host(organization.host)
      login_as department_admin, scope: :user
      visit decidim_admin_assemblies.assemblies_path
      within "tr", text: translated(parent_assembly.title) do
        click_link_or_button "Assemblies"
      end
    end

    # it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
  end
end
