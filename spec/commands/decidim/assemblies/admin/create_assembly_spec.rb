# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssembly do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:department) { create(:department, organization:) }
    let(:current_user) { create(:department_admin, :confirmed, organization:, department:) }
    let(:form_attributes) do
      {
        title: { en: "title" },
        subtitle: { en: "subtitle" },
        weight: 1,
        slug: "slug",
        hashtag: nil,
        description: { en: "description" },
        short_description: { en: "short_description" },
        promoted: false,
        taxonomizations: [],
        parent: nil,
        announcement: {},
        organization:,
        private_space: false,
        developer_group: {},
        local_area: {},
        target: {},
        participatory_scope: {},
        participatory_structure: {},
        meta_scope: {},
        purpose_of_action: {},
        composition: {},
        creation_date: nil,
        created_by: nil,
        created_by_other: {},
        duration: nil,
        included_at: nil,
        closing_date: nil,
        closing_date_reason: {},
        internal_organisation: {},
        is_transparent: false,
        special_features: {},
        twitter_handler: nil,
        facebook_handler: nil,
        instagram_handler: nil,
        youtube_handler: nil,
        github_handler: nil,
        decidim_department_admin_department_id: nil,
      }
    end
    let(:form) do
      double(
        invalid?: false,
        current_user:,
        current_organization: organization,
        hero_image: nil,
        banner_image: nil,
        participatory_processes_ids: [],
        **form_attributes
      )
    end

    let(:assembly) { Decidim::Assembly.last }

    it "assigns the department of the department_admin even if the form does not send it" do
      expect { subject.call }.to broadcast(:ok)
      expect(assembly.decidim_department_admin_department_id).to eq(department.id)
    end

    context "when another decorator redefines run_after_hooks after the gem is loaded" do
      around do |example|
        original = described_class.instance_method(:run_after_hooks).super_method

        described_class.class_eval do
          protected

          def run_after_hooks
            Decidim::ContentBlocksCreator.new(resource).create_default!
          end
        end

        example.run
      ensure
        described_class.send(:define_method, :run_after_hooks, original)
        described_class.send(:protected, :run_after_hooks)
      end

      it "still assigns the department of the department_admin" do
        expect(described_class.instance_method(:run_after_hooks).super_method.source_location.first).to eq(__FILE__)

        expect { subject.call }.to broadcast(:ok)
        expect(assembly.decidim_department_admin_department_id).to eq(department.id)
      end
    end
  end
end
