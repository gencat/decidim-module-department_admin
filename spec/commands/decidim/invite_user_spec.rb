# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUser do
    describe "call" do
      let(:organization) { create(:organization) }

      let(:current_user) { create(:admin, :confirmed, organization:) }

      let(:form_params) do
        {
          name: "user_name",
          email: "user_name@example.org",
          organization:,
        }
      end

      let(:form) do
        InviteUserForm.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_user:
        )
      end

      let(:command) { described_class.new(form, current_user) }

      shared_examples_for "inviting_users" do
        context "when everything is ok" do
          it "invites the user with no area" do
            invite_user
            user = Decidim::User.find_by(email: "user_name@example.org")
            expect(user).to exist
          end
        end
      end
    end
  end
end
