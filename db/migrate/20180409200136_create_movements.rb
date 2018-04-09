class CreateMovements < ActiveRecord::Migration[5.1]
  def change
    create_table :movements do |t|
      t.references :harbour, foreign_key: true
      t.references :type, foreign_key: true
      t.integer :year
      t.string :terminal
      t.string :pol_pod
      t.integer :volume

      t.timestamps
    end
  end
end
