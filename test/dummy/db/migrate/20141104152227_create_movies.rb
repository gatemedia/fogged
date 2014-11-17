class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies, :force => true do |t|
      t.string :name

      t.timestamps
    end
  end
end
