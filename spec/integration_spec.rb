# frozen_string_literal: true

require 'spec_helper'

describe "Integration", aggregate_failures: true, db: true do
  let!(:subscription1) do
    create(:webhook_subscription, :active, :encrypted, :with_topics, url: 'http://lvh.me/hook1', topics: ['other_event'])
  end
  let!(:subscription2) do
    create(:webhook_subscription, :active, :plain, :with_topics, url: 'http://lvh.me/hook2', topics: ['other_event'])
  end

  let(:event_class) do
    Class.new(WebhookSystem::BaseEvent) do
      def event_name
        'other_event'
      end

      def payload_attributes
        %i[
          name
          age
        ]
      end

      attribute :name, type: String
      attribute :age, type: Integer

      validates :name, presence: true
      validates :age, presence: true
    end
  end

  let(:event) { event_class.build(name: 'John', age: 21) }

  let(:expected_payload) do
    {
      'event_name' => 'other_event',
      'name' => 'John',
      'age' => 21,
    }
  end

  def handle_webhook(to:)
    stub_request(:post, to).with(body: /.*/).to_return do |request|
      yield(request)
      {
        status: [200, 'OK'],
        body: 'Success',
        headers: { 'Hello' => 'World' },
      }
    end
  end

  example 'encrypted and plain payloads' do
    hooks_called = []
    handle_webhook(to: 'http://lvh.me/hook1') do |request|
      hooks_called << :hook1
      expect(request.headers['Content-Type']).to eq('application/json; base64+aes256')
      payload = WebhookSystem::Encoder.decode('some-secret', request.body, request.headers)
      payload.delete('event_id') # because its a random thing
      expect(payload).to eq(expected_payload)
    end

    handle_webhook(to: 'http://lvh.me/hook2') do |request|
      hooks_called << :hook2
      expect(request.headers['Content-Type']).to eq('application/json')
      payload = WebhookSystem::Encoder.decode('some-secret', request.body, request.headers)
      payload.delete('event_id') # because its a random thing
      expect(payload).to eq(expected_payload)
    end

    perform_enqueued_jobs do
      WebhookSystem::Subscription.dispatch event
    end

    expect(hooks_called).to match_array(%i[hook1 hook2])
  end
end
