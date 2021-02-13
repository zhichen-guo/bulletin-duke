class CreateJoinTableOrganizationUser < ActiveRecord::Migration[6.0]
  def change
    create_join_table :organizations, :users do |t|
      t.index :organization_id
      t.index :user_id
    end
  end
end
