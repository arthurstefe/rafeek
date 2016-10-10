class CreatePackages < ActiveRecord::Migration[5.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :description
      t.string :image
      t.integer :points
      t.decimal :value

      t.timestamps
    end
  end
end