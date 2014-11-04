class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.integer :resource_id

      t.timestamps
    end
  end
end
