class CreateChallenges < ActiveRecord::Migration[6.0]
  def change
    create_table :challenges do |t|
      t.string :title
      t.text :description
      t.integer :goal
      t.string :type
      t.date :start
      t.date :end

      t.timestamps
    end
  end
end
