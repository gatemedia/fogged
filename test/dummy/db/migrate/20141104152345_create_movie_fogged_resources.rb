class CreateMovieFoggedResources < ActiveRecord::Migration
  def change
    create_table :movie_fogged_resources, :force => true do |t|
      t.belongs_to :movie, :index => true
      t.belongs_to :resource, :index => true

      t.timestamps
    end
  end
end
