class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :encoded
      t.string :decoded
      t.integer :level

      t.timestamps
    end
  end
end
