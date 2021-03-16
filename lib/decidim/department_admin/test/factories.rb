# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :department_admin, parent: :user do
    roles { ["department_admin"] }
    transient do
      area { nil }
    end

    after(:build) do |user, evaluator|
      user.areas << evaluator.area if evaluator.area.present?
    end
  end
end
