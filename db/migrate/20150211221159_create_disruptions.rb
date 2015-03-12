class CreateDisruptions < ActiveRecord::Migration
  def change
    create_table :disruptions do |t|
      t.string :route
      t.string :direction
      t.string :fromStopName
      t.string :fromStopCode
      t.string :toStopName
      t.string :toStopCode
      t.integer :delay
      t.integer :routeTotalDelay
      t.integer :trend
      t.string :timeFirstDetected

      t.timestamps null: false
    end
  end
end
