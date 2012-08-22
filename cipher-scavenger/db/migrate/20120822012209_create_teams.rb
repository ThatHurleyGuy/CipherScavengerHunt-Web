class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
    	t.string :name
    	t.integer :pin
    	t.integer :score

    	t.timestamps
    end
    create_table :messages do |t|
    	t.integer :team_id
    	t.string :encoded
    	t.string :decoded
    	t.string :parity
    	t.integer :level

    	t.timestamps
    end
  end
end
