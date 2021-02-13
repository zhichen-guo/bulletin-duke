class AddInterfaceToOAuthStrategies < ActiveRecord::Migration[6.0]
  def change
    add_reference :o_auth_strategies, :interface
  end
end
