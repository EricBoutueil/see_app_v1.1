class RemoveWebsiteFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :website
  end
end
