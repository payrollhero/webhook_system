require 'spec_helper'

describe WebhookSystem, aggregate_failures: true, db: true do
  describe 'dispatching' do
    let!(:subscription1) do
      create(:webhook_subscription, :active, :with_topics, url: 'http://lvh.me/hook1', topics: ['other_event'])
    end

    let!(:subscription2) do
      create(:webhook_subscription, :active, :with_topics, url: 'http://lvh.me/hook2', topics: ['some_event'])
    end

    let(:event_class) do
      Class.new(WebhookSystem::BaseEvent) do
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
    end

    let(:event) { event_class.build(name: "John", age: 21) }

    it 'fires the jobs' do
      headers = { 'Content-Type' => 'application/json; base64+aes256' }
      stub = stub_request(:post, 'http://lvh.me/hook1').with(body: /.*/, headers: headers)

      perform_enqueued_jobs do
        described_class.dispatch event
      end

      expect(stub).to have_been_requested.once
    end
  end
end
