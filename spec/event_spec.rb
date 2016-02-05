require 'spec_helper'

describe WebhookSystem, aggregate_failures: true do
  let(:widget_class) do
    Class.new do
      include PhModel
      attribute :foo
      attribute :bar

      def as_json
        { foo: foo, bar: bar }
      end
    end
  end

  let(:test_payload_attributes) do
    [
      :widget,
      :name,
    ]
  end

  let(:event_class) do
    local_test_payload_attributes = test_payload_attributes
    Class.new(WebhookSystem::BaseEvent) do
      def event_name
        "sample_event"
      end

      define_method(:payload_attributes) do
        local_test_payload_attributes
      end

      attribute :widget, type: ::Widget
      attribute :name, type: String

      def the_name
        "The #{name}"
      end

      validates :name, presence: true
      validates :widget, presence: true
    end
  end

  before do
    stub_const('Widget', widget_class)
    stub_const('SampleEvent', event_class)
  end

  describe 'Base Event' do
    let(:widget) { widget_class.build(foo: 'Yay', bar: 'Bla') }
    let(:event) { event_class.build widget: widget, name: 'Bob' }

    context "with array attribute list" do
      describe "#as_json" do
        let(:expected) do
          {
            'event' => 'sample_event',
            'widget' => {
              'foo' => 'Yay',
              'bar' => 'Bla',
            },
            'name' => 'Bob',
          }
        end

        example do
          expect(event.as_json).to eq(expected)
        end
      end
    end

    context "with hash attribute list" do
      describe "#as_json" do
        let(:expected) do
          {
            'event' => 'sample_event',
            'the_widget' => {
              'foo' => 'Yay',
              'bar' => 'Bla',
            },
            'name' => 'The Bob',
          }
        end

        let(:test_payload_attributes) do
          {
            the_widget: :widget,
            name: :the_name,
          }
        end

        example do
          expect(event.as_json).to eq(expected)
        end
      end
    end


    describe "#event_name" do
      example { expect(event.event_name).to eq('sample_event') }
    end
  end
end
