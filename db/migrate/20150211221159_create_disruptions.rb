class CreateDisruptions < ActiveRecord::Migration
  def change
    create_table :disruptions do |t|
      t.string :route
      t.string :direction
      t.string :startStop
      t.string :endStop
      t.integer :disruptionObserved
      t.integer :trend
      t.string :timeFirstDetected

      t.timestamps null: false
    end
  end
end
