# frozen_string_literal: true

require 'spec_helper'

module Decidim
  describe Area do
    subject(:area) { create(:area) }

    context 'when depending participatory process exist' do
      let!(:department_admin) do
        user = create(:user, :confirmed, organization: area.organization)
        user.roles << 'department_admin'
        user.areas << area
        user.save!
        user
      end

      it 'can not be deleted' do
        expect(area.destroy).to be false
      end
    end
  end
end
