# frozen_string_literal: true

require 'spec_helper'

describe WebhookSystem::Encoder, aggregate_failures: true do
  let(:secret1) { 'Hello World' }
  let(:secret2) { 'Bye World' }

  let(:sample_data) do
    {
      'hello' => 'World',
    }
  end

  context 'using base64+aes256' do
    let(:format) { 'base64+aes256' }

    example 'with good key pair' do
      encoded, headers = described_class.encode(secret1, sample_data, format: format)
      expect(headers['X-Hub-Signature']).to match(/^sha1=/)
      expect(headers['Content-Type']).to eq('application/json; base64+aes256')

      decoded = described_class.decode(secret1, encoded, headers)

      expect(decoded).to eq(sample_data)
    end

    example 'with mismatched keys' do
      encoded, headers = described_class.encode(secret1, sample_data, format: format)
      expect(headers['X-Hub-Signature']).to match(/^sha1=/)
      expect(headers['Content-Type']).to eq('application/json; base64+aes256')

      expect {
        described_class.decode(secret2, encoded, headers)
      }.to raise_exception(WebhookSystem::DecodingError, 'signature mismatch')
    end
  end

  context 'using hub-signature' do
    let(:format) { 'json' }

    example 'matching key' do
      encoded, headers = described_class.encode(secret1, sample_data, format: format)
      expect(headers['X-Hub-Signature']).to match(/^sha1=/)
      expect(headers['Content-Type']).to eq('application/json')

      decoded = described_class.decode(secret1, encoded, headers)
      expect(decoded).to eq(sample_data)
    end

    example 'mismatch key' do
      encoded, headers = described_class.encode(secret1, sample_data, format: format)
      expect(headers['X-Hub-Signature']).to match(/^sha1=/)
      expect(headers['Content-Type']).to eq('application/json')

      expect {
        described_class.decode(secret2, encoded, headers)
      }.to raise_exception(WebhookSystem::DecodingError, 'signature mismatch')
    end
  end
end
