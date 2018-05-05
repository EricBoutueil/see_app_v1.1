ActiveAdmin.register Movement do

  menu priority: 2, label: proc{ t('ar.model.movements') }

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


  permit_params :harbour_id, :type_id, :year, :volume, :terminal, :pol_pod

  index do
    selectable_column
    column :id
    column :harbour
    column :type
    # column :type_title
    column :year
    column :volume
    column :terminal
    column :pol_pod
    actions
  end

end
