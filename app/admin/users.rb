ActiveAdmin.register User do

  menu priority: 5, label: proc{ t('ar.model.users') }

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

  permit_params :email, :password, :first_name, :last_name, :phone_number, :company_name, :admin

  form do |f|
    inputs 'Details' do
      semantic_errors
      input :email
      input :password
      input :first_name
      input :last_name
      input :phone_number
      input :company_name
      input :admin
    end
    actions
  end

  index do
    selectable_column
    column :id
    column :email
    column :name
    # column :company_name
    # column :phone_number
    column :created_at
    column :last_sign_in_at
    column :sign_in_count
    column :admin
    actions
  end

end
