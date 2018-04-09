class ChangeFlowToInteger < ActiveRecord::Migration[5.1]
  def change
    remove_column :types, :flow
    add_column :types, :flow, :integer
  end
end
