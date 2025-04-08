require 'rails_helper'

RSpec.describe "Analytics", type: :request do
  describe "GET /analytics" do
    before do
      3.times do |i|
        SearchQuery.create!(
          ip_address: "127.0.0.1",
          final_query: "test query #{i}",
          timestamp: Time.current - i.hours
        )
      end
    end

    it "renders the analytics template" do
      get analytics_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it "assigns the correct variables" do
      get analytics_path
      expect(assigns(:top_searches)).to be_present
      expect(assigns(:top_searches_today)).to be_present
      expect(assigns(:recent_user_searches)).to be_present
    end
  end
end
