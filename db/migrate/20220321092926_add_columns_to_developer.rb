class AddColumnsToDeveloper < ActiveRecord::Migration[6.1]
  def change
    add_column :developers, :name, :string
    add_column :developers, :repositories, :numeric
    add_column :developers, :location, :string
  end
end
