class RemoveTypeFromChallenges < ActiveRecord::Migration[6.0]
  def change
    remove_column :challenges, :type
    add_column :challenges, :challenge_type, :boolean
  end
end
