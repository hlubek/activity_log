class CreateActivityEntry < ActiveRecord::Migration
  def self.up
    create_table :activity_entries do |t|
      t.string :action
      t.references :entity, :polymorphic => true
      # TODO this should be "user" by default (or even better configurable)
      t.references :account
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :activity_entries
  end
end
