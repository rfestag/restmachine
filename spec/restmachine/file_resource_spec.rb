require 'spec_helper'
require './spec/restmachine/applications/files'

describe Restmachine::FileResource do
  include Webmachine::Test

  let(:app) {FilesApp}

  describe 'Serving static files' do
    it 'should return 200 and the file with an appropriate content-type when the file exists' do
      get '/some_file.txt'
      expect(response.code).to eq(200)
    end
    it 'should return 404 if the file does not exist' do
      get '/i_do_not_exist'
      expect(response.code).to eq(404)
    end
    it 'should return 403 if the application server does not have permission to read the file' do
      get '/bad_perms'
      expect(response.code).to eq(403)
    end
  end
end
