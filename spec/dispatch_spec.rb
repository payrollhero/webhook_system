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
          'other_event'
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

    let(:event) { event_class.build(name: 'John', age: 21) }
    let(:subscription1_hook_stub) {
      headers = { 'Content-Type' => 'application/json; base64+aes256' }
      stub_request(:post, 'http://lvh.me/hook1').with(body: /.*/, headers: headers)
    }

    describe 'successful delivery' do
      it 'fires the jobs' do
        stub = subscription1_hook_stub.to_return(status: [200, 'OK'],
                                                 body: 'Success',
                                                 headers: { 'Hello' => 'World' })

        expect {
          perform_enqueued_jobs do
            described_class.dispatch event
          end
        }.to change { subscription1.event_logs.count }.by(1)

        expect(stub).to have_been_requested.once

        log = subscription1.event_logs.last

        expect(log.status).to eq(200)
        expect(log.response['body']).to eq('Success')
        expect(log.response['headers']).to eq('hello' => 'World')
      end
    end

    describe 'failed delivery' do
      it 'fires the jobs' do
        stub = subscription1_hook_stub.to_return(status: [400, 'Bad Request'],
                                                 body: "I don't like you",
                                                 headers: { 'Hello' => 'World' })

        expect {
          expect {
            perform_enqueued_jobs do
              described_class.dispatch event
            end
          }.to change { subscription1.event_logs.count }.by(1)
        }.to raise_exception(WebhookSystem::Job::RequestFailed, 'request failed with code: 400')

        expect(stub).to have_been_requested.once

        log = subscription1.event_logs.last

        expect(log.status).to eq(400)
        expect(log.response['body']).to eq("I don't like you")
        expect(log.response['headers']).to eq('hello' => 'World')
      end
    end

    describe 'exception occurs during the delivery' do
      it 'fires the jobs' do
        subscription1_hook_stub.to_raise(StandardError.new('exception message'))

        expect {
          expect {
            perform_enqueued_jobs do
              described_class.dispatch event
            end
          }.to change { subscription1.event_logs.count }.by(1)
        }.to raise_exception(WebhookSystem::Job::RequestFailed, 'request failed with code: 0')

        log = subscription1.event_logs.last

        expect(log.status).to eq(0)
        expect(log.response['body']).to match(%r(StandardError\nexception message\n))
        expect(log.response['headers']).to eq({})
      end
    end
  end
end
