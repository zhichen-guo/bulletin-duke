class CreateOAuthStrategies < ActiveRecord::Migration[6.0]
  def change
    create_table :o_auth_strategies do |t|
      t.string :name
      t.string :client_id
      t.string :client_secret
      t.string :redirect_url
      t.boolean :configured

      t.timestamps
    end
  end
end
