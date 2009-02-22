ActiveRecord::Schema.define(:version => 0) do
  drop_table "thingybobs"
  create_table "thingybobs", :force => true do |t|
    t.string "name", :null => false
  end

  drop_table "activity_entries"
  create_table "activity_entries", :force => true do |t|
    t.string   "action"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "account_id"
    t.datetime "created_at"
  end
end