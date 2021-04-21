# frozen_string_literal: true

# Intercepts the `call` method and forces the Area of the user if it is a
# department_admin user.
Decidim::Conferences::Admin::CreateConference.class_eval do
  alias_method :original_call, :call

  def call
    author = form.current_user
    form.area_id = author.areas.first.id if author.department_admin?
    original_call
  end

  private

  def conference
    @conference ||= Decidim.traceability.create(
      Decidim::Conference,
      form.current_user,
      organization: form.current_organization,
      title: form.title,
      slogan: form.slogan,
      slug: form.slug,
      hashtag: form.hashtag,
      description: form.description,
      short_description: form.short_description,
      objectives: form.objectives,
      location: form.location,
      scopes_enabled: form.scopes_enabled,
      scope: form.scope,
      start_date: form.start_date,
      end_date: form.end_date,
      hero_image: form.hero_image,
      banner_image: form.banner_image,
      promoted: form.promoted,
      show_statistics: form.show_statistics,
      registrations_enabled: form.registrations_enabled,
      available_slots: form.available_slots || 0,
      registration_terms: form.registration_terms,
      area: form.area
    )
  end
end
