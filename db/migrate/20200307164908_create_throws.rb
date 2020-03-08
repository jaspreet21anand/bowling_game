class CreateThrows < ActiveRecord::Migration[6.0]
  def change
    create_table :throws do |t|
      t.integer :knocked_pins
      t.integer :frame_id
      t.integer :knock_type

      t.timestamps
    end
    add_index :throws, :frame_id
    add_index :throws, :created_at
  end
end
