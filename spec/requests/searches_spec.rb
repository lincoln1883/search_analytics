require 'rails_helper'

RSpec.describe "Searches", type: :request do
  include ActiveJob::TestHelper

  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /searches" do
    let(:valid_params) { { query: "test search" } }
    
    it "creates a SearchEvent" do
      expect {
        post searches_path, params: valid_params, as: :json
      }.to change(SearchEvent, :count).by(1)
    end

    it "enqueues ProcessSearchEventsJob" do
      expect {
        post searches_path, params: valid_params, as: :json
      }.to have_enqueued_job(ProcessSearchEventsJob)
    end

    it "returns a turbo stream response" do
      post searches_path, params: valid_params, 
           headers: { 'Accept': 'text/vnd.turbo-stream.html' }
      
      expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
      expect(response).to have_http_status(:success)
    end
  end
end
