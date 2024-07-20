class ChangeTypeOfFuel < ActiveRecord::Migration[7.1]
  def change
    change_column :cars, :fuel, :string
  end
end
