ActiveAdmin.register Type do

  menu priority: 3, label: proc{ t('activerecord.model.types') }

  actions :all, except: [:destroy]

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

  permit_params :code, :flow, :label, :unit, :description

  index do
    selectable_column
    column :id
    column :code
    column(:flow) { |obj| t("activerecord.attributes.type.flows.#{obj.flow}") }
    column :label
    column :unit
    column :description
    actions
  end

end
