class AddTimeZoneToInterface < ActiveRecord::Migration[6.0]
  def change
    add_column :interfaces, :time_zone, :string
  end
end
