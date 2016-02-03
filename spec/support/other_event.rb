class OtherEvent < WebhookSystem::BaseEvent

  def event_name
    "other_event"
  end

  def payload_attributes
    [
      :name,
      :age,
    ]
  end

  attribute :name, type: String
  attribute :age, type: Fixnum

  validates :name, presence: true
  validates :age, presence: true

end
