class CreateFrames < ActiveRecord::Migration[6.0]
  def change
    create_table :frames do |t|
      t.integer :score
      t.integer :game_id
      t.integer :state

      t.timestamps
    end
    add_index :frames, :game_id
    add_index :frames, :state
    add_index :frames, :created_at
  end
end
