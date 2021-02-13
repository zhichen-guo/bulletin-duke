class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone
      t.boolean :car
      t.integer :user_type

      t.timestamps
    end
  end
end
