class AddUnitToTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :types, :unit, :string
  end
end
