# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters" do
  let(:organization) { create(:organization) }
  let(:area) { create(:area, organization:) }
  let!(:department_admin) { create(:department_admin, :confirmed, name: "Sarah Kerrigan", organization:, area:) }
  let!(:deliverable_users) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization:) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  def wait_redirect
    sleep(0.5)
  end

  def fill_newsletter_form
    fill_in_i18n(
      :newsletter_subject,
      "#newsletter-subject-tabs",
      en: "A fancy newsletter for %{name}",
      es: "Un correo electrónico muy chulo para %{name}",
      ca: "Un correu electrònic flipant per a %{name}"
    )

    fill_in_i18n_editor(
      :newsletter_settings_body,
      "#newsletter-settings--body-tabs",
      en: "Hello %{name}! Relevant content.",
      es: "Hola, %{name}! Contenido relevante.",
      ca: "Hola, %{name}! Contingut rellevant."
    )
  end

  context "when creating and previewing a newsletter" do
    it "allows a newsletter to be created" do
      visit decidim_admin.newsletters_path

      find(".button.new").click

      within "#image_text_cta" do
        click_on "Use this template"
      end

      within ".new_newsletter" do
        fill_newsletter_form
      end

      within ".new_newsletter" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("Preview")
      expect(page).to have_content("A fancy newsletter for #{department_admin.name}")
    end
  end

  context "with existing newsletter" do
    let!(:newsletter) do
      create(:newsletter,
             organization:,
             subject: {
               en: "A fancy newsletter for %{name}",
               es: "Un correo electrónico muy chulo para %{name}",
               ca: "Un correu electrònic flipant per a %{name}",
             },
             body: {
               en: "Hello %{name}! Relevant content.",
               es: "Hola, %{name}! Contenido relevante.",
               ca: "Hola, %{name}! Contingut rellevant.",
             },
             author: department_admin)
    end

    it "previews a newsletter" do
      visit decidim_admin.newsletter_path(newsletter)

      expect(page).to have_content("A fancy newsletter for Sarah Kerrigan")
      expect(page).to have_css("iframe.email-preview[src=\"#{decidim_admin.preview_newsletter_path(newsletter)}\"]")

      visit decidim_admin.preview_newsletter_path(newsletter)
      expect(page).to have_content("Hello Sarah Kerrigan! Relevant content.")
    end
  end

  context "when updating the newsletter" do
    let!(:newsletter) do
      create(:newsletter, organization:,
                          subject: {
                            en: "A fancy newsletter for %{name}",
                            es: "Un correo electrónico muy chulo para %{name}",
                            ca: "Un correu electrònic flipant per a %{name}",
                          },
                          body: {
                            en: "Hello %{name}! Relevant content.",
                            es: "Hola, %{name}! Contenido relevante.",
                            ca: "Hola, %{name}! Contingut rellevant.",
                          },
                          author: department_admin)
    end

    it "allows a newsletter to be updated" do
      visit decidim_admin.newsletters_path
      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        click_on "Edit"
      end

      within ".edit_newsletter" do
        fill_newsletter_form
      end

      expect(page).to have_content("Save and preview")
      # expect(page).to have_content("A fancy newsletter")
    end
  end

  context "when selecting newsletter recipients" do
    let!(:newsletter) { create(:newsletter, organization:, author: department_admin) }

    context "when followers are selected" do
      let!(:participatory_processes) { create_list(:participatory_process, 2, organization:, area:) }
      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: participatory_processes.first, user: follower)
        end
      end

      it "sends to followers" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            check("Send to followers")
            uncheck("Send to participants")
            within ".participatory_processes-block" do
              select translated(participatory_processes.first.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "form.newsletter_deliver .item__edit-sticky" do
            accept_confirm { click_on("Deliver newsletter") }
          end

          wait_redirect
          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end
    end

    context "when participants are selected" do
      let!(:participatory_process) { create(:participatory_process, organization:, area:) }
      let!(:component) { create(:dummy_component, organization: newsletter.organization, participatory_space: participatory_process) }

      before do
        deliverable_users.each do |participant|
          create(:dummy_resource, component:, author: participant, published_at: Time.current)
        end
      end

      it "sends to participants" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            uncheck("Send to followers")
            check("Send to participants")
            within ".participatory_processes-block" do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "form.newsletter_deliver .item__edit-sticky" do
            accept_confirm { click_on("Deliver newsletter") }
          end

          wait_redirect
          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
          expect(page).to have_content("Has been sent to")
          within "tbody" do
            expect(page).to have_content("5 / 5")
          end
        end
      end
    end

    context "when selecting both followers and participants" do
      let!(:participatory_process) { create(:participatory_process, organization:, area:) }
      let!(:component) { create(:dummy_component, organization: newsletter.organization, participatory_space: participatory_process) }

      let!(:followers) do
        deliverable_users.each do |follower|
          create(:follow, followable: component.participatory_space, user: follower)
        end
      end

      before do
        deliverable_users.each do |participant|
          create(:dummy_resource, component:, author: participant, published_at: Time.current)
        end
      end

      it "sends to participants" do
        visit decidim_admin.select_recipients_to_deliver_newsletter_path(newsletter)
        perform_enqueued_jobs do
          within(".newsletter_deliver") do
            check("Send to followers")
            check("Send to participants")
            within ".participatory_processes-block" do
              select translated(component.participatory_space.title), from: :newsletter_participatory_space_types_participatory_processes__ids
            end
          end

          within "form.newsletter_deliver .item__edit-sticky" do
            accept_confirm { click_on("Deliver newsletter") }
          end

          wait_redirect
          expect(page).to have_content("Newsletters")
          expect(page).to have_admin_callout("successfully")
        end

        within "tbody" do
          expect(page).to have_content("5 / 5")
        end
      end
    end
  end

  context "when deleting a newsletter" do
    let!(:newsletter) { create(:newsletter, organization:, author: department_admin) }

    it "deletes a newsletter" do
      visit decidim_admin.newsletters_path

      within("tr[data-newsletter-id=\"#{newsletter.id}\"]") do
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_content("successfully")
      expect(page).to have_no_css("tr[data-newsletter-id=\"#{newsletter.id}\"]")
    end
  end
end
