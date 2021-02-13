class AddActiveToChallenges < ActiveRecord::Migration[6.0]
  def change
    add_column :challenges, :active, :boolean
  end
end
