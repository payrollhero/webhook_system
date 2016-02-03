require 'spec_helper'

describe WebhookSystem::Encoder, aggregate_failures: true do
  let(:secret1) { 'Hello World' }
  let(:secret2) { 'Bye World' }

  let(:sample_data) { 'Hello World' }

  example 'with good key pair' do
    encoded = described_class.encode(secret1, sample_data)
    decoded = described_class.decode(secret1, encoded)

    expect(decoded).to eq(sample_data)
  end

  example 'with mismatched keys' do
    encoded = described_class.encode(secret1, sample_data)

    expect {
      described_class.decode(secret2, encoded)
    }.to raise_exception(WebhookSystem::DecodingError, 'Decoding Failed, probably mismatched secret')
  end
end
