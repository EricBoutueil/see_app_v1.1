class CreateTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :types do |t|
      t.string :code
      t.string :label
      t.string :flow
      t.string :description

      t.timestamps
    end
  end
end
