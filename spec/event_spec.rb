require 'spec_helper'

describe WebhookSystem, aggregate_failures: true do
  describe 'Base Event' do
    let(:event) do
      widget = SampleEvent::Widget.new
      widget.foo = 'Yay'
      widget.bar = 'Bla'
      SampleEvent.build widget: widget, name: 'Bob'
    end

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

    describe "#event_name" do
      example { expect(event.event_name).to eq('sample_event') }
    end
  end
end
