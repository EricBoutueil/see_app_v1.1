class AddColCguAcceptedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cgu_accepted, :boolean, default: false, null: false
  end
end
