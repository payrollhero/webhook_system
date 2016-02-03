ActiveRecord::Schema.define(version: 1) do
  create_table :webhook_subscriptions do |t|
    t.string :url
    t.boolean :active
    t.text :secret

    t.index :active
  end

  create_table :webhook_subscription_topics do |t|
    t.string :name
    t.belongs_to :subscription

    t.index :subscription_id
    t.index :name
  end
end
