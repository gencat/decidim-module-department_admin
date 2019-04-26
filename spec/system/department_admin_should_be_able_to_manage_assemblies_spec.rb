# frozen_string_literal: true

require 'spec_helper'

describe 'Admin manages assemblies', versioning: true, type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization: organization) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  shared_examples 'creating an assembly' do
    let(:image1_filename) { 'city.jpeg' }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { 'city2.jpeg' }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      visit decidim_admin_assemblies.assemblies_path
      click_link 'New assembly'
    end

    it 'creates a new assembly' do
      within '.new_assembly' do
        fill_in_i18n(
          :assembly_title,
          '#assembly-title-tabs',
          en: 'My assembly',
          es: 'Mi proceso participativo',
          ca: 'El meu procés participatiu'
        )
        fill_in_i18n(
          :assembly_subtitle,
          '#assembly-subtitle-tabs',
          en: 'Subtitle',
          es: 'Subtítulo',
          ca: 'Subtítol'
        )
        fill_in_i18n_editor(
          :assembly_short_description,
          '#assembly-short_description-tabs',
          en: 'Short description',
          es: 'Descripción corta',
          ca: 'Descripció curta'
        )
        fill_in_i18n_editor(
          :assembly_description,
          '#assembly-description-tabs',
          en: 'A longer description',
          es: 'Descripción más larga',
          ca: 'Descripció més llarga'
        )

        fill_in :assembly_slug, with: 'slug'
        fill_in :assembly_hashtag, with: '#hashtag'
        attach_file :assembly_hero_image, image1_path
        attach_file :assembly_banner_image, image2_path

        find('*[type=submit]').click
      end

      expect(page).to have_admin_callout('successfully')
      expect(Decidim::Assembly.last.area).to eq(area)

      within '.container' do
        # expect(page).to have_current_path decidim_admin_assemblies.assemblies_path(parent_id: parent_assembly&.id)
        expect(page).to have_content('My assembly')
      end
    end
  end

  context 'when managing parent assemblies' do
    let(:parent_assembly) { nil }

    before do
      visit decidim_admin_assemblies.assemblies_path
    end
    # it_behaves_like "manage assemblies"
    it_behaves_like 'creating an assembly'
  end

  context 'when managing child assemblies' do
    let!(:parent_assembly) { create :assembly, organization: organization, area: area }
    let!(:child_assembly) { create :assembly, organization: organization, parent: parent_assembly, area: area }
    let(:assembly) { child_assembly }

    before do
      visit decidim_admin_assemblies.assemblies_path
      within find('tr', text: translated(parent_assembly.title)) do
        click_link 'Assemblies'
      end
    end

    # it_behaves_like "manage assemblies"
    it_behaves_like 'creating an assembly'
  end
end
