require 'spec_helper'

module RackPassword
  describe TimeToken do
    let(:time_token) { TimeToken.new(code: 'timecode') }
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
  end
end
