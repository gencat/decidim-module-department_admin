# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :department, class: "Decidim::DepartmentAdmin::Department" do
    name { generate_localized_title }
    organization
  end

  factory :department_admin, parent: :user do
    roles { ["department_admin"] }
    admin_terms_accepted_at { Time.zone.now }
    transient do
      area { nil }
      department { nil }
    end

    after(:build) do |user, evaluator|
      user.areas << evaluator.area if evaluator.area.present?
      user.departments << evaluator.department if evaluator.department.present?
    end
  end
end
