class CreateInterfaces < ActiveRecord::Migration[6.0]
  def change
    create_table :interfaces do |t|
      t.boolean :customized
      t.string :name
      t.string :tag_line
      t.string :institution
      t.string :primary_color
      t.string :secondary_color
      t.string :accent_color

      t.timestamps
    end
  end
end
