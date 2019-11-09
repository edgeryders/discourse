# frozen_string_literal: true

require_relative './spec_helper'

describe ::Discourse::Cors do
  context 'with cors origins' do
    it 'should append api-key and api-username to accepted CORS headers' do
      result = Discourse::Cors.apply_headers(['origin.eu'], {}, {})
      expect(result['Access-Control-Allow-Headers']).to match /\,\sApi-Key/
      expect(result['Access-Control-Allow-Headers']).to match /\,\sApi-Username/
    end
  end

  context 'without cors origins' do
    it 'should not append additional CORS headers' do
      result = Discourse::Cors.apply_headers([], {}, {})
      expect(result['Access-Control-Allow-Headers']).to_not match /\,\sApi-Key/
      expect(result['Access-Control-Allow-Headers']).to_not match /\,\sApi-Username/
    end
  end
end
