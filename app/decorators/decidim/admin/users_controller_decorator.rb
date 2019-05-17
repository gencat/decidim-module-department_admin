# frozen_string_literal: true

require_dependency 'decidim/admin/users_controller'

::Decidim::Admin::UsersController.class_eval do
  alias_method :original_collection, :collection

  def collection
    users= original_collection
    @collection||= users.select('*', 'array_to_string(roles) AS sorted_roles').order('sorted_roles')
    puts ">>>>>>>@#{@collection.pluck(:roles)}"
    Kaminari.paginate_array(@collection.sort { |u1, u2| "#{u1.active_role}||#{u1.areas.first}" <=> "#{u2.active_role}||#{u2.areas.first}" })
  end
end
