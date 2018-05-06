class AddDefaultToStrings < ActiveRecord::Migration[5.1]
  def change
    change_column :harbours, :name, :string, :default => ""
    change_column :types, :code, :string, :default => ""
    change_column :types, :label, :string, :default => ""
    change_column :types, :unit, :string, :default => ""
    change_column :types, :description, :string, :default => ""
    change_column :movements, :terminal, :string, :default => ""
    change_column :movements, :pol_pod, :string, :default => ""
  end
end
