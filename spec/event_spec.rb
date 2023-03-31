# frozen_string_literal: true

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
    %i[
      widget
      name
    ]
  end

  let(:event_class) do
    # this is a hack to inject a let variable into the class definition
    local_test_payload_attributes = test_payload_attributes
    Class.new(WebhookSystem::BaseEvent) do
      def event_name
        'sample_event'
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

    context 'with array attribute list' do
      describe '#as_json' do
        let(:expected) do
          {
            'event_name' => 'sample_event',
            'event_id' => event.event_id,
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

    context 'with hash attribute list' do
      describe '#as_json' do
        let(:expected) do
          {
            'event_name' => 'sample_event',
            'event_id' => event.event_id,
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

    context 'defining a reserved attribute' do
      describe '#as_json' do
        let(:test_payload_attributes) do
          {
            event: :name,
          }
        end

        example do
          expect {
            event.as_json
          }.to raise_exception(ArgumentError, 'SampleEvent should not be defining an attribute named event since its reserved')
        end
      end
    end

    describe '#event_name' do
      example { expect(event.event_name).to eq('sample_event') }
    end

    describe 'event_id' do
      let(:event1) { event_class.build widget: widget, name: 'Bob' }
      let(:event2) { event_class.build widget: widget, name: 'Bob2' }
      let(:guid_regex) { /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/ }

      example do
        expect(event1.event_id).to be_present
        expect(event1.event_id).to be_a(String)
        expect(event1.event_id).to match(guid_regex)
        expect(event1.event_id).to_not eq(event2.event_id)
      end
    end
  end
end
