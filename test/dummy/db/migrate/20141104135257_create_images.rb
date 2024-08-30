# frozen_string_literal: true
class CreateImages < ActiveRecord::Migration
  def change
    create_table :images, force: true do |t|
      t.string :name
      t.integer :resource_id

      t.timestamps
    end
  end
end
