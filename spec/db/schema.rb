ActiveRecord::Schema.define(version: 1) do
  create_table :webhook_subscriptions do |t|
    t.string :url, null: false
    t.boolean :active, null: false
    t.text :secret

    t.index :active
  end

  create_table :webhook_subscription_topics do |t|
    t.string :name, null: false
    t.belongs_to :subscription, null: false

    t.index :subscription_id
    t.index :name
  end

  create_table :webhook_event_logs do |t|
    t.belongs_to :subscription, null: false

    t.string :event_name, null: false
    t.string :event_id, null: false
    t.integer :status, null: false

    t.text :request, limit: 64_000, null: false
    t.text :response, limit: 64_000, null: false

    t.datetime :created_at, null: false

    t.index :created_at
    t.index :event_name
    t.index :status
    t.index :subscription_id
    t.index :event_id
  end
end
