# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes", :versioning do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:) }

  let!(:participatory_process_groups) do
    create_list(:participatory_process_group, 3, organization:)
  end

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  # it_behaves_like "manage processes examples"
  # it_behaves_like "manage processes announcements"

  context "with processes" do
    let!(:participatory_process) { create(:participatory_process, organization:, area:, participatory_process_group: participatory_process_groups.first) }

    it "browses the list of processes" do
      visit decidim_admin_participatory_processes.participatory_processes_path
      expect(page).to have_content(translated(participatory_process.title))
    end
  end

  context "when creating a participatory process" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      click_on "New process"
    end

    it "creates a new participatory process with department admin's area" do
      within ".new_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "My participatory process",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :participatory_process_subtitle,
          "#participatory_process-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :participatory_process_short_description,
          "#participatory_process-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :participatory_process_description,
          "#participatory_process-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        group_name = participatory_process_groups.first.title["en"]
        select group_name, from: :participatory_process_participatory_process_group_id

        fill_in :participatory_process_slug, with: "slug"
        fill_in :participatory_process_hashtag, with: "#hashtag"
      end

      dynamically_attach_file(:participatory_process_hero_image, image1_path)
      dynamically_attach_file(:participatory_process_banner_image, image2_path)

      within ".new_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(Decidim::ParticipatoryProcess.last.area).to eq(area)

      within ".card#steps" do
        expect(page).to have_current_path decidim_admin_participatory_processes.participatory_process_steps_path(Decidim::ParticipatoryProcess.last)
        expect(page).to have_content("Phases")
        expect(page).to have_content("Introduction")
      end
    end
  end

  context "when updating a participatory process" do
    let!(:participatory_process_3) { create(:participatory_process, organization:, area:) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "update a participatory process without images does not delete them" do
      click_on translated(participatory_process_3.title)
      within_admin_sidebar_menu do
        click_on "About this process"
      end

      click_on "Update"

      expect(participatory_process_3.reload.area).to eq(area)
      expect(page).to have_admin_callout("successfully")
      expect(page).to have_css("img[src*='#{participatory_process_3.attached_uploader(:hero_image).path}']")
      expect(page).to have_css("img[src*='#{participatory_process_3.attached_uploader(:banner_image).path}']")
    end
  end
end
