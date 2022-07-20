# frozen_string_literal: true

require 'spec_helper'

describe WebhookSystem, aggregate_failures: true, db: true do
  describe 'validations' do
    example 'invalid url' do
      expect {
        create(:webhook_subscription, url: '')
      }.to raise_exception(ActiveRecord::RecordInvalid, /Url is not a valid URL/)

      expect {
        create(:webhook_subscription, url: 'hello')
      }.to raise_exception(ActiveRecord::RecordInvalid, /Url is not a valid URL/)

      expect {
        create(:webhook_subscription, url: 'foo@bar.com')
      }.to raise_exception(ActiveRecord::RecordInvalid, /Url is not a valid URL/)

      expect {
        create(:webhook_subscription, url: 'ftp://asdsad')
      }.to raise_exception(ActiveRecord::RecordInvalid, /Url is not a valid URL/)

      # Missing on /
      expect {
        create(:webhook_subscription, url: 'http:/ok.org/webhook')
      }.to raise_exception(ActiveRecord::RecordInvalid, /Url is not a valid URL/)

      # HTTP remains valid
      expect {
        create(:webhook_subscription, url: 'http://ok.org/webhook')
      }.to_not raise_exception

      # HTTPS is considered default
      expect {
        create(:webhook_subscription, url: 'https://ok.org/webhook')
      }.to_not raise_exception

      # Inline is too call jobs directly, no web calls
      expect {
        create(:webhook_subscription, url: 'inline:Rockstar')
      }.to_not raise_exception
    end

    describe 'url_domain' do
      it 'returns the domain of the url by default' do
        expect(create(:webhook_subscription, url: 'http://example.org/bingo/is/a/sport.html').url_domain).to eq "example.org"
      end

      it 'returns the right end part of inline subscriptions' do
        expect(create(:webhook_subscription, url: 'inline:AutoFillTrivia').url_domain).to eq "AutoFillTrivia"
      end
    end
  end

  describe 'creating and finding subscriptions' do
    let(:subscription1) { create(:webhook_subscription, :active) }
    let(:subscription2) { create(:webhook_subscription, :active) }
    let(:subscription3) { create(:webhook_subscription) }

    before do
      subscription1.topics.create!(name: 'one')
      subscription1.topics.create!(name: 'two')
    end

    before do
      subscription2.topics.create!(name: 'two')
      subscription2.topics.create!(name: 'three')
    end

    before do
      subscription3.topics.create!(name: 'one')
      subscription3.topics.create!(name: 'two')
      subscription3.topics.create!(name: 'three')
    end

    it 'properly finds those subscriptions' do
      expect(WebhookSystem::Subscription.interested_in_topic('one')).to match_array([subscription1])
      expect(WebhookSystem::Subscription.interested_in_topic('two')).to match_array([subscription1, subscription2])
      expect(WebhookSystem::Subscription.interested_in_topic('three')).to match_array([subscription2])
    end
  end
end
