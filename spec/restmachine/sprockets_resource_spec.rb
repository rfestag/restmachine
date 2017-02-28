require 'spec_helper'
require './spec/restmachine/applications/sprockets'

describe Restmachine::SprocketsResource do
  include Webmachine::Test

  let(:app) {SprocketsApp}

  describe 'Serving generated assets' do
    it 'should return concatenated javascript' do
      get '/assets/application.js'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/javascript')
      expect(response.body).to include('test1')
      expect(response.body).to include('bar')
    end
    it 'should return concatenated css' do
      get '/assets/application.css'
      expect(response.code).to eq(200)
      expect(response.headers['Content-Type']).to eq('text/css')
      expect(response.body).to include('application')
      expect(response.body).to include('css1')
      expect(response.body).to include('tree1')
      expect(response.body).to include('tree2')
    end
  end
end
