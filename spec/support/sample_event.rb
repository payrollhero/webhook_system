class SampleEvent < WebhookSystem::BaseEvent

  class Widget
    attr_accessor :foo
    attr_accessor :bar
  end

  def event_name
    "sample_event"
  end

  def payload_attributes
    [
      :widget,
      :name,
    ]
  end

  attribute :widget, type: Widget
  attribute :name, type: String

  validates :name, presence: true
  validates :widget, presence: true

end
