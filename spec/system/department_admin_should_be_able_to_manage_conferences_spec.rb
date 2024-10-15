# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conferences", :versioning do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  shared_examples "creating an conference" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      visit decidim_admin_conferences.assemblies_path
      click_on "New conference"
    end

    it "creates a new conference" do
      within ".new_conference" do
        fill_in_i18n(
          :conference_title,
          "#conference-title-tabs",
          en: "My conference",
          es: "Mi conferencia",
          ca: "Mi jornada"
        )
        fill_in_i18n(
          :conference_subtitle,
          "#conference-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :conference_short_description,
          "#conference-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :conference_description,
          "#conference-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in :conference_slug, with: "slug"
        fill_in :conference_hashtag, with: "#hashtag"
        attach_file :conference_hero_image, image1_path
        attach_file :conference_banner_image, image2_path

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(Decidim::Conference.last.area).to eq(area)

      within ".container" do
        expect(page).to have_content("My conference")
      end
    end
  end
end
