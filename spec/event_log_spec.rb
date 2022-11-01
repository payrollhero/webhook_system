# frozen_string_literal: true

require 'spec_helper'

describe WebhookSystem::EventLog, db: true do
  let(:subscription_id) { 1 }
  let(:event_id) { 2 }
  let(:event_name) { 'do_something' }
  let(:status) { 200 }
  let(:request) { {} }
  let(:response) { {} }

  context 'validations' do
    subject(:log) do
      build(:webhook_event_log,
            subscription_id: subscription_id,
            event_id: event_id,
            event_name: event_name,
            status: status,
            request: request,
            response: response)
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    context 'event_id' do
      let(:event_id) { nil }

      it 'validates presence of event_id' do
        expect(subject).to_not be_valid
      end
    end

    context 'subscription_id' do
      let(:subscription_id) { nil }

      it 'validates presence of subscription_id' do
        expect(subject).to_not be_valid
      end
    end

    context 'event_name' do
      let(:event_name) { nil }

      it 'validates presence of event_name' do
        expect(subject).to_not be_valid
      end
    end

    context 'status' do
      let(:status) { nil }

      it 'validates presence of status' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe '#construct' do
    subject(:log) do
      described_class.construct(subscription, event, request, response)
    end

    let(:subscription) { create(:webhook_subscription) }
    let(:event) { { 'event_name' => event_name, 'event_id' => event_id } }
    let(:request) { double(:request, headers: {}, body: 'a' * 64_000, path: 'url') }
    let(:response) { double(:request, headers: {}, body: 'b' * 64_000, status: status) }

    context 'request/response body is bigger than 60K' do
      it 'truncates request body to 60K' do
        subject.save!
        expect(subject.request['body'].length).to eq(40_000)
      end

      it 'truncates response body to 60K' do
        subject.save!
        expect(subject.response['body'].length).to eq(40_000)
      end
    end
  end
end
