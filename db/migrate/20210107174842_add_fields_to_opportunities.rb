class AddFieldsToOpportunities < ActiveRecord::Migration[6.0]
  def change
    add_column :opportunities, :remote, :boolean
    add_column :opportunities, :link, :string
  end
end
