class AddSuccessToChallenges < ActiveRecord::Migration[6.0]
  def change
    add_column :challenges, :success, :boolean
  end
end
