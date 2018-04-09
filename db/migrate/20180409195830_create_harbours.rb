class CreateHarbours < ActiveRecord::Migration[5.1]
  def change
    create_table :harbours do |t|
      t.string :country
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
