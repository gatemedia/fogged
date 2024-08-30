# frozen_string_literal: true
class CreateFoggedResources < ActiveRecord::Migration
  def change
    create_table :fogged_resources do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.integer :width
      t.integer :height
      t.string :extension, null: false
      t.boolean :uploading # rubocop:disable Rails/ThreeStateBooleanColumn
      t.string :content_type, null: false
      t.integer :encoding_progress
      t.string :encoding_job_id
      t.integer :duration

      t.timestamps
    end

    add_index :fogged_resources, :token
  end
end
