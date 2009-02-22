class ActivityEntry < ActiveRecord::Base
  unloadable

  belongs_to :entity, :polymorphic => true
  # FIXME change to user (or make configurable)
  belongs_to :account
  
  named_scope :recent, :order => 'created_at DESC'
end