require 'spec_helper'

module RackPassword
  describe TimeToken do
    let(:time_token) { TimeToken.new(%w(secret1 secret2)) }
    let(:valid_until) { (Time.now + 60).to_s }
    let(:token) { time_token.generate(valid_until) }

    describe 'correct time token' do
      it 'returns true' do
        expect(time_token.valid?(token, valid_until)).to eq true
      end
    end

    describe 'for empty parameters' do
      it 'returns false' do
        expect(time_token.valid?('', '')).to eq false
      end
    end

    describe 'for wrong parameters' do
      it 'returns false' do
        expect(time_token.valid?('21312', valid_until)).to eq false
      end
    end

    describe 'for expired token' do
      let(:old_time) { (Time.now - 5).to_s }
      let(:expired_token) { time_token.generate(old_time) }
      it 'returns false' do
        expect(time_token.valid?(expired_token, old_time)).to eq false
      end
    end

    describe 'for spoofed time until' do
      let(:time_now) { Time.now }
      let(:valid_until) { Time.now + 10 }
      let(:spoofed_valid_until) { valid_until + 60 * 60 }
      let(:token) { time_token.generate(valid_until) }
      it 'returns true for correct time' do
        expect(time_token.valid?(token, valid_until.to_s)).to eq true
      end

      it 'returns false for spoofed time' do
        expect(time_token.valid?(token, spoofed_valid_until.to_s)).to eq false
      end
    end
  end
end
