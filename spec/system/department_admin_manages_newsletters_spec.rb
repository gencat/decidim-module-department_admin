# frozen_string_literal: true

require 'spec_helper'

describe 'Admin manages newsletters', type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization: organization) }
  let(:department_admin) { create(:department_admin, :confirmed, name: 'Sarah Kerrigan', organization: organization, area: area) }
  let!(:deliverable_users) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  def wait_redirect
    sleep(0.5)
  end

  context 'creates and previews a newsletter' do
    it 'allows a newsletter to be created' do
      visit decidim_admin.newsletters_path

      within '.secondary-nav' do
        find('.button.new').click
      end

      within '.new_newsletter' do
        fill_in_i18n(
          :newsletter_subject,
          '#newsletter-subject-tabs',
          en: 'A fancy newsletter for %{name}',
          es: 'Un correo electrónico muy chulo para %{name}',
          ca: 'Un correu electrònic flipant per a %{name}'
        )

        fill_in_i18n_editor(
          :newsletter_body,
          '#newsletter-body-tabs',
          en: 'Hello %{name}! Relevant content.',
          es: 'Hola, %{name}! Contenido relevante.',
          ca: 'Hola, %{name}! Contingut rellevant.'
        )

        find('*[type=submit]').click
      end

      expect(page).to have_content('PREVIEW')
      expect(page).to have_content("A fancy newsletter for #{department_admin.name}")
    end
  end

  context 'with existing newsletter' do
    let!(:newsletter) do
      create(:newsletter,
             organization: organization,
             subject: {
               en: 'A fancy newsletter for %{name}',
               es: 'Un correo electrónico muy chulo para %{name}',
               ca: 'Un correu electrònic flipant per a %{name}'
             },
             body: {
               en: 'Hello %{name}! Relevant content.',
               es: 'Hola, %{name}! Contenido relevante.',
               ca: 'Hola, %{name}! Contingut rellevant.'
             },
             author: department_admin)
    end

    it 'previews a newsletter' do
      visit decidim_admin.newsletter_path(newsletter)

      expect(page).to have_content('A fancy newsletter for Sarah Kerrigan')
      expect(page).to have_css("iframe.email-preview[src=\"#{decidim_admin.preview_newsletter_path(newsletter)}\"]")

      visit decidim_admin.preview_newsletter_path(newsletter)
      expect(page).to have_content('Hello Sarah Kerrigan! Relevant content.')
    end
  end

  context 'update newsletter' do
    let!(:newsletter) { create(:newsletter, organization: organization, author: department_admin) }

    it 'allows a newsletter to be updated' do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        click_link 'Edit'
      end

      within '.edit_newsletter' do
        fill_in_i18n(
          :newsletter_subject,
          '#newsletter-subject-tabs',
          en: 'A fancy newsletter',
          es: 'Un correo electrónico muy chulo',
          ca: 'Un correu electrònic flipant'
        )

        fill_in_i18n_editor(
          :newsletter_body,
          '#newsletter-body-tabs',
          en: 'Relevant content.',
          es: 'Contenido relevante.',
          ca: 'Contingut rellevant.'
        )

        find('*[type=submit]').click
      end

      expect(page).to have_content('PREVIEW')
      expect(page).to have_content('A fancy newsletter')
    end
  end

  context 'select newsletter recipients' do
    let!(:newsletter) { create(:newsletter, organization: organization, author: department_admin) }

    context 'when followers are selected' do
      let!(:participatory_processes) { create_list(:participatory_process, 2, organization: organization, area: area) }
      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: participatory_processes.first, user: follower)
        end
      end

      it 'sends to followers' do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within('.newsletter_deliver') do
            check('Send to followers')
            uncheck('Send to participants')
            within '.participatory_processes-block' do
              select translated(participatory_processes.first.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within '.button--double' do
            accept_confirm { find('*', text: 'Deliver').click }
          end

          wait_redirect
          expect(page).to have_content('NEWSLETTERS')
          expect(page).to have_admin_callout('successfully')
        end

        within 'tbody' do
          expect(page).to have_content('5 / 5')
        end
      end
    end

    context 'when participants are selected' do
      let!(:participatory_process) { create(:participatory_process, organization: organization, area: area) }
      let!(:component) { create(:dummy_component, organization: newsletter.organization, participatory_space: participatory_process) }

      before do
        deliverable_users.each do |participant|
          create(:dummy_resource, component: component, author: participant, published_at: Time.current)
        end
      end

      it 'sends to participants' do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within('.newsletter_deliver') do
            uncheck('Send to followers')
            check('Send to participants')
            within '.participatory_processes-block' do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within '.button--double' do
            accept_confirm { find('*', text: 'Deliver').click }
          end

          wait_redirect
          expect(page).to have_content('NEWSLETTERS')
          expect(page).to have_admin_callout('successfully')
          expect(page).to have_content('Has been sent to')
          within 'tbody' do
            expect(page).to have_content('5 / 5')
          end
        end

      end
    end

    context 'when selecting both followers and participants' do
      let!(:participatory_process) { create(:participatory_process, organization: organization, area: area) }
      let!(:component) { create(:dummy_component, organization: newsletter.organization, participatory_space: participatory_process) }

      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: component.participatory_space, user: follower)
        end
      end

      before do
        deliverable_users.each do |participant|
          create(:dummy_resource, component: component, author: participant, published_at: Time.current)
        end
      end

      it 'sends to participants' do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within('.newsletter_deliver') do
            check('Send to followers')
            check('Send to participants')
            within '.participatory_processes-block' do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within '.button--double' do
            accept_confirm { find('*', text: 'Deliver').click }
          end

          wait_redirect
          expect(page).to have_content('NEWSLETTERS')
          expect(page).to have_admin_callout('successfully')
        end

        within 'tbody' do
          expect(page).to have_content('5 / 5')
        end
      end
    end
  end

  context 'deleting a newsletter' do
    let!(:newsletter) { create(:newsletter, organization: organization, author: department_admin) }

    it 'deletes a newsletter' do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        accept_confirm { click_link 'Delete' }
      end

      expect(page).to have_content('successfully')
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
