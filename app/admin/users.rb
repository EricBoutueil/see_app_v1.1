ActiveAdmin.register User do

  actions :all

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  # permit_params :email, :first_name, :last_name, :company_name

  index do
    selectable_column
    column :id
    column :email
    column :name
    column :created_at
    column :last_sign_in_at
    column :sign_in_count
    column :admin
    actions
  end

end
