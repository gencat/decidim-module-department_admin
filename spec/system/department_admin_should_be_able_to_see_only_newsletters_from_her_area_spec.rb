# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters", :versioning do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:department) { create(:department, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, department:) }

  let!(:newsletter_w_department) do
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

  let!(:newsletter_wo_department) do
    create(:newsletter,
           organization:,
           subject: {
             en: "A fancy newsletter for %{name} without department",
             es: "Un correo electrónico muy chulo para %{name} sin departamento",
             ca: "Un correu electrònic flipant per a %{name} sense departament",
           },
           body: {
             en: "Hello %{name}! Relevant content.",
             es: "Hola, %{name}! Contenido relevante.",
             ca: "Hola, %{name}! Contingut rellevant.",
           },
           author: admin)
  end

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin.newsletters_path
  end

  it "sees only newsletters in the same department" do
    expect(page).to have_content(newsletter_w_department.subject["en"])
    expect(page).to have_no_content(newsletter_wo_department.subject["en"])
  end
end
