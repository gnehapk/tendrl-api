require 'spec_helper'

describe 'Application' do

  before do
    #TODO fetch from fixtures
    @cluster_id = 'd74371ad-c292-4ccd-949c-d48de9472afd'
    @osd_id = '371e9305-a17c-4314-bc4a-849098a95f96' 
    @pool_id = 0
  end

  it 'pong' do
    get '/ping' 
    expect(last_response.status).to eq 200
  end

  context 'Clusters' do

    it 'list' do
      get '/clusters', { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

    it 'details' do
      get "/clusters/#{@cluster_id}", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

  end

  context 'Osds' do

    it 'list' do
      get "/clusters/#{@cluster_id}/osds", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

    it 'details' do
      get "/clusters/#{@cluster_id}/osds/#{@osd_id}", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

  end

  context 'Pools' do

    it 'list' do
      get "/clusters/#{@cluster_id}/pools", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

    it 'details' do
      get "/clusters/#{@cluster_id}/pools/#{@pool_id}", { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 200
      #body = JSON.parse(last_response.body)
    end

  end


end
